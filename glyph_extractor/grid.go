package main

import (
	"image"
	"image/color"
)

// GridConfig holds the configuration for the grid extraction
type GridConfig struct {
	CellWidthMM  float64 // Cell width in mm (22.5)
	CellHeightMM float64 // Cell height in mm (26.2)
	Columns      int     // Number of columns (8)
	Rows         int     // Number of rows (10)
	DPI          int     // Scanner DPI (default 300)
	MarginTopMM  float64 // Top margin in mm
	MarginLeftMM float64 // Left margin in mm
}

// DefaultConfig returns the default grid configuration
func DefaultConfig() GridConfig {
	return GridConfig{
		CellWidthMM:  22.5,
		CellHeightMM: 26.2,
		Columns:      8,
		Rows:         10,
		DPI:          300,
		MarginTopMM:  10.0,  // Default 10mm top margin
		MarginLeftMM: 10.0,  // Default 10mm left margin
	}
}

// mmToPixels converts millimeters to pixels based on DPI
func (c GridConfig) mmToPixels(mm float64) int {
	// 1 inch = 25.4 mm
	inches := mm / 25.4
	return int(inches * float64(c.DPI))
}

// CellWidthPx returns cell width in pixels
func (c GridConfig) CellWidthPx() int {
	return c.mmToPixels(c.CellWidthMM)
}

// CellHeightPx returns cell height in pixels
func (c GridConfig) CellHeightPx() int {
	return c.mmToPixels(c.CellHeightMM)
}

// MarginTopPx returns top margin in pixels
func (c GridConfig) MarginTopPx() int {
	return c.mmToPixels(c.MarginTopMM)
}

// MarginLeftPx returns left margin in pixels
func (c GridConfig) MarginLeftPx() int {
	return c.mmToPixels(c.MarginLeftMM)
}

// CellsPerPage returns the number of cells per page
func (c GridConfig) CellsPerPage() int {
	return c.Columns * c.Rows
}

// ExtractCell extracts a single cell from the image at the given row and column
func (c GridConfig) ExtractCell(img image.Image, row, col int) image.Image {
	cellW := c.CellWidthPx()
	cellH := c.CellHeightPx()
	marginTop := c.MarginTopPx()
	marginLeft := c.MarginLeftPx()

	x := marginLeft + col*cellW
	y := marginTop + row*cellH

	rect := image.Rect(x, y, x+cellW, y+cellH)
	return cropImage(img, rect)
}

// cropImage crops the image to the given rectangle
func cropImage(img image.Image, rect image.Rectangle) image.Image {
	// Ensure rect is within image bounds
	bounds := img.Bounds()
	rect = rect.Intersect(bounds)

	cropped := image.NewRGBA(image.Rect(0, 0, rect.Dx(), rect.Dy()))
	for y := rect.Min.Y; y < rect.Max.Y; y++ {
		for x := rect.Min.X; x < rect.Max.X; x++ {
			cropped.Set(x-rect.Min.X, y-rect.Min.Y, img.At(x, y))
		}
	}
	return cropped
}

// TrimWhitespace removes whitespace around the glyph and returns the trimmed image
// along with the bounding box information.
// Uses a stricter ink detection threshold (half the transparency threshold) to ignore
// JPEG compression artifacts while still finding real ink strokes.
func TrimWhitespace(img image.Image, threshold uint8) (image.Image, image.Rectangle) {
	bounds := img.Bounds()
	minX, minY := bounds.Max.X, bounds.Max.Y
	maxX, maxY := bounds.Min.X, bounds.Min.Y

	// Use a stricter threshold for trim detection — we want to find actual ink,
	// not JPEG artifacts. Ink is typically much darker than artifacts.
	inkThreshold := int(threshold) * 3 / 4
	if inkThreshold > 255 {
		inkThreshold = 255
	}

	// Find bounding box of non-white pixels
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			r, g, b, _ := img.At(x, y).RGBA()
			// Convert to 8-bit
			r8 := uint8(r >> 8)
			g8 := uint8(g >> 8)
			b8 := uint8(b >> 8)

			// Check if pixel is ink (all channels below stricter threshold)
			if r8 < uint8(inkThreshold) && g8 < uint8(inkThreshold) && b8 < uint8(inkThreshold) {
				if x < minX {
					minX = x
				}
				if x > maxX {
					maxX = x
				}
				if y < minY {
					minY = y
				}
				if y > maxY {
					maxY = y
				}
			}
		}
	}

	// If no content found, return original image
	if minX > maxX || minY > maxY {
		return img, bounds
	}

	// Add small padding (2 pixels)
	padding := 2
	minX = max(bounds.Min.X, minX-padding)
	minY = max(bounds.Min.Y, minY-padding)
	maxX = min(bounds.Max.X, maxX+padding+1)
	maxY = min(bounds.Max.Y, maxY+padding+1)

	trimRect := image.Rect(minX, minY, maxX, maxY)
	return cropImage(img, trimRect), trimRect
}

// MakeTransparent converts white background to transparent with smooth alpha edges.
// Three zones based on pixel lightness (max RGB channel):
//   - Dark pixels (< inkOpaque): fully opaque ink, keeps original color
//   - Mid pixels (inkOpaque..threshold): smooth alpha gradient for anti-aliased edges
//   - Light pixels (>= threshold): fully transparent background
func MakeTransparent(img image.Image, threshold uint8) image.Image {
	bounds := img.Bounds()
	result := image.NewNRGBA(bounds)

	// Pixels darker than this are considered solid ink (fully opaque).
	// Use 3/4 of threshold to keep the gradient zone narrow — only the
	// lightest edge pixels get partial transparency.
	inkOpaque := int(threshold) * 3 / 4

	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			r, g, b, _ := img.At(x, y).RGBA()
			r8 := uint8(r >> 8)
			g8 := uint8(g >> 8)
			b8 := uint8(b >> 8)

			// Use the maximum channel as the "lightness" indicator
			maxCh := int(r8)
			if int(g8) > maxCh {
				maxCh = int(g8)
			}
			if int(b8) > maxCh {
				maxCh = int(b8)
			}

			if maxCh >= int(threshold) {
				// Light pixel — fully transparent background
				result.SetNRGBA(x, y, color.NRGBA{R: 0, G: 0, B: 0, A: 0})
			} else if maxCh <= inkOpaque {
				// Dark pixel — fully opaque ink
				result.SetNRGBA(x, y, color.NRGBA{R: r8, G: g8, B: b8, A: 255})
			} else {
				// Transition zone — smooth gradient from opaque to transparent
				// Map [inkOpaque..threshold] → alpha [255..0]
				span := int(threshold) - inkOpaque
				alpha := 255 * (int(threshold) - maxCh) / span
				result.SetNRGBA(x, y, color.NRGBA{R: r8, G: g8, B: b8, A: uint8(alpha)})
			}
		}
	}
	return result
}

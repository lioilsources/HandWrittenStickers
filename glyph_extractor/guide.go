package main

import (
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"os"
	"strings"

	xdraw "golang.org/x/image/draw"
	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/font/sfnt"
	"golang.org/x/image/math/fixed"
)

// A4 at 300 DPI, the size the Grid Alignment tool exports.
const (
	a4WidthPx  = 2480
	a4HeightPx = 3508
)

// GuideOptions configures the clean-font guide sheets that an img2img model
// "re-materialises" (plan M1). The output uses the exact template geometry,
// so the generated pages go straight into `extract`.
type GuideOptions struct {
	FontPath string
	Outputs  []string // one PNG per page (2 pages = 160 chars)
	MaskPath string   // optional grid mask (white lines on black) for ControlNet
	DPI      int
	EmRatio  float64
	CapRatio float64
	// MaxFill is the largest fraction of the cell width/height a glyph may
	// occupy; wider glyphs are scaled down so neighbours never touch.
	MaxFill float64
}

func DefaultGuideOptions() GuideOptions {
	return GuideOptions{DPI: 300, EmRatio: 0.62, CapRatio: 0.70, MaxFill: 0.80}
}

func generateGuide(opts GuideOptions) error {
	data, err := os.ReadFile(opts.FontPath)
	if err != nil {
		return fmt.Errorf("reading font: %w", err)
	}
	parsed, err := opentype.Parse(data)
	if err != nil {
		return fmt.Errorf("parsing font: %w", err)
	}
	cfg := GridConfig{CellWidthMM: 22.5, CellHeightMM: 26.2, Columns: 8, Rows: 10,
		DPI: opts.DPI, MarginTopMM: 15, MarginLeftMM: 15}
	cellW, cellH := cfg.CellWidthPx(), cfg.CellHeightPx()
	emPx := float64(cellH) * opts.EmRatio
	baselineY := int(float64(cellH) * 0.75)

	newFace := func(px float64) (font.Face, error) {
		return opentype.NewFace(parsed, &opentype.FaceOptions{
			Size: px * 72 / float64(opts.DPI), DPI: float64(opts.DPI), Hinting: font.HintingNone,
		})
	}
	face, err := newFace(emPx)
	if err != nil {
		return err
	}
	if capPx := measureInkHeight(face, 'H'); opts.CapRatio > 0 && capPx > 0 {
		face.Close()
		if face, err = newFace(emPx * opts.CapRatio * emPx / float64(capPx)); err != nil {
			return err
		}
	}
	defer face.Close()

	pageW := max(a4WidthPx, cfg.MarginLeftPx()*2+cellW*cfg.Columns)
	pageH := max(a4HeightPx, cfg.MarginTopPx()+cellH*cfg.Rows)
	if opts.DPI != 300 {
		pageW = cfg.mmToPixels(210)
		pageH = cfg.mmToPixels(297)
	}

	var buf sfnt.Buffer
	var missing []string
	perPage := cfg.CellsPerPage()
	for page, out := range opts.Outputs {
		canvas := image.NewNRGBA(image.Rect(0, 0, pageW, pageH))
		draw.Draw(canvas, canvas.Bounds(), image.White, image.Point{}, draw.Src)
		for i := 0; i < perPage; i++ {
			idx := page*perPage + i
			if idx >= len(Charset) {
				break
			}
			r := Charset[idx]
			if gi, err := parsed.GlyphIndex(&buf, r); err != nil || gi == 0 {
				missing = append(missing, string(r))
				continue
			}
			glyph, baseline := renderGuideGlyph(face, r, cellW, cellH)
			if glyph == nil {
				continue
			}
			// Keep the glyph inside MaxFill of the cell, scaling around the baseline.
			gb := glyph.Bounds()
			s := min(1.0,
				opts.MaxFill*float64(cellW)/float64(gb.Dx()),
				opts.MaxFill*float64(cellH)/float64(gb.Dy()))
			if s < 1 {
				nw, nh := int(float64(gb.Dx())*s), int(float64(gb.Dy())*s)
				scaled := image.NewNRGBA(image.Rect(0, 0, nw, nh))
				xdraw.CatmullRom.Scale(scaled, scaled.Bounds(), glyph, gb, xdraw.Src, nil)
				glyph, baseline = scaled, int(float64(baseline)*s)
			}
			row, col := i/cfg.Columns, i%cfg.Columns
			x0 := cfg.MarginLeftPx() + col*cellW + (cellW-glyph.Bounds().Dx())/2
			y0 := cfg.MarginTopPx() + row*cellH + baselineY - baseline
			// Keep descenders inside the cell.
			if over := y0 + glyph.Bounds().Dy() - (cfg.MarginTopPx() + (row+1)*cellH - cellH/20); over > 0 {
				y0 -= over
			}
			dst := image.Rect(x0, y0, x0+glyph.Bounds().Dx(), y0+glyph.Bounds().Dy())
			draw.Draw(canvas, dst, glyph, image.Point{}, draw.Over)
		}
		if err := savePNG(canvas, out); err != nil {
			return err
		}
		fmt.Printf("Guide page %d → %s (%dx%d px)\n", page+1, out, pageW, pageH)
	}
	if len(missing) > 0 {
		fmt.Printf("Font lacks %d characters (cells left empty): %s\n", len(missing), strings.Join(missing, " "))
	}

	if opts.MaskPath != "" {
		mask := image.NewGray(image.Rect(0, 0, pageW, pageH))
		lw := max(2, opts.DPI/100)
		white := image.NewUniform(color.Gray{255})
		for c := 0; c <= cfg.Columns; c++ {
			x := cfg.MarginLeftPx() + c*cellW
			draw.Draw(mask, image.Rect(x-lw/2, cfg.MarginTopPx(), x-lw/2+lw, cfg.MarginTopPx()+cfg.Rows*cellH), white, image.Point{}, draw.Src)
		}
		for r := 0; r <= cfg.Rows; r++ {
			y := cfg.MarginTopPx() + r*cellH
			draw.Draw(mask, image.Rect(cfg.MarginLeftPx(), y-lw/2, cfg.MarginLeftPx()+cfg.Columns*cellW, y-lw/2+lw), white, image.Point{}, draw.Src)
		}
		if err := savePNG(mask, opts.MaskPath); err != nil {
			return err
		}
		fmt.Printf("Grid mask → %s\n", opts.MaskPath)
	}
	return nil
}

// renderGuideGlyph draws r in black on transparent and returns it cropped to
// the ink together with the baseline position inside the crop.
func renderGuideGlyph(face font.Face, r rune, cellW, cellH int) (*image.NRGBA, int) {
	canvas := image.NewNRGBA(image.Rect(0, 0, cellW*3, cellH*2))
	originY := cellH
	d := &font.Drawer{
		Dst:  canvas,
		Src:  image.NewUniform(color.NRGBA{0, 0, 0, 255}),
		Face: face,
		Dot:  fixed.P(cellW, originY),
	}
	d.DrawString(string(r))
	trimmed, rect := trimAlpha(canvas, 0)
	if rect.Empty() {
		return nil, 0
	}
	// Flatten onto white so img2img sees plain black-on-white letters.
	return trimmed, originY - rect.Min.Y
}

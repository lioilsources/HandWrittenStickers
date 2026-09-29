package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"os"
	"path/filepath"
	"strings"

	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/font/sfnt"
	"golang.org/x/image/math/fixed"
)

// GlyphMetrics describes where a trimmed glyph PNG sits relative to the
// typographic baseline and how far the cursor should advance after it.
// All values are in pixels of the source sheet (see ManifestV2.EmHeight).
type GlyphMetrics struct {
	Width    int `json:"w"`        // trimmed PNG width
	Height   int `json:"h"`        // trimmed PNG height
	Baseline int `json:"baseline"` // px from top of PNG down to the baseline
	Advance  int `json:"advance"`  // horizontal advance (px) from glyph origin
	Bearing  int `json:"bearing"`  // px from glyph origin to left edge of PNG
}

// ManifestV2 is the glyph sheet manifest. It is a superset of the v1 format:
// the "glyphs" map is unchanged so older readers keep working, and the
// per-glyph "metrics" allow proper baseline alignment and proportional spacing.
type ManifestV2 struct {
	Version       int                     `json:"version"`
	ID            string                  `json:"id"`
	Name          string                  `json:"name"`
	Source        string                  `json:"source"` // "font" or "handwriting"
	License       string                  `json:"license,omitempty"`
	Attribution   string                  `json:"attribution,omitempty"`
	CellSize      CellSize                `json:"cellSize"`
	DPI           int                     `json:"dpi"`
	EmHeight      int                     `json:"emHeight"`      // nominal em size in px; renderer scales all glyphs by targetEm/emHeight
	BaselineRatio float64                 `json:"baselineRatio"` // baseline position within a cell (0..1 from top)
	Glyphs        map[string]string       `json:"glyphs"`
	Metrics       map[string]GlyphMetrics `json:"metrics,omitempty"`
}

// FontSetOptions controls rasterisation of a font into a glyph sheet.
type FontSetOptions struct {
	FontPath    string
	OutputDir   string
	ID          string
	Name        string
	License     string
	Attribution string
	DPI         int
	// EmRatio is the font size relative to the cell height (0.62 ≈ what a
	// typical hand-written letter occupies in the 26.2 mm template cell).
	EmRatio float64
	// Padding in px kept around the ink after trimming.
	Padding int
}

// DefaultFontSetOptions returns options matching the paper template geometry.
func DefaultFontSetOptions() FontSetOptions {
	return FontSetOptions{
		DPI:     300,
		EmRatio: 0.62,
		Padding: 2,
	}
}

// generateFontSet rasterises every rune of Charset with the given TTF/OTF font
// and writes <output>/<file>.png plus <output>/glyphs.json (ManifestV2).
// Runes the font does not cover are reported and omitted from the manifest.
func generateFontSet(opts FontSetOptions) error {
	data, err := os.ReadFile(opts.FontPath)
	if err != nil {
		return fmt.Errorf("reading font: %w", err)
	}
	parsed, err := opentype.Parse(data)
	if err != nil {
		return fmt.Errorf("parsing font: %w", err)
	}

	cfg := GridConfig{
		CellWidthMM:  22.5,
		CellHeightMM: 26.2,
		Columns:      8,
		Rows:         10,
		DPI:          opts.DPI,
	}
	cellW := cfg.CellWidthPx()
	cellH := cfg.CellHeightPx()
	emPx := int(float64(cellH) * opts.EmRatio)
	baselineRatio := 0.75
	baselineY := int(float64(cellH) * baselineRatio)

	// Point size such that 1 em == emPx pixels at the chosen DPI.
	sizePt := float64(emPx) * 72.0 / float64(opts.DPI)
	face, err := opentype.NewFace(parsed, &opentype.FaceOptions{
		Size:    sizePt,
		DPI:     float64(opts.DPI),
		Hinting: font.HintingNone,
	})
	if err != nil {
		return fmt.Errorf("creating face: %w", err)
	}
	defer face.Close()

	if err := os.MkdirAll(opts.OutputDir, 0755); err != nil {
		return err
	}

	// Canvas is wider than a cell so wide glyphs (W, ™, …) are not clipped.
	canvasW := cellW * 3
	canvasH := cellH * 2
	originX := cellW // glyph origin (pen position) x
	originY := baselineY + cellH/2

	manifest := ManifestV2{
		Version:       2,
		ID:            opts.ID,
		Name:          opts.Name,
		Source:        "font",
		License:       opts.License,
		Attribution:   opts.Attribution,
		CellSize:      CellSize{Width: cfg.CellWidthMM, Height: cfg.CellHeightMM},
		DPI:           opts.DPI,
		EmHeight:      emPx,
		BaselineRatio: baselineRatio,
		Glyphs:        map[string]string{},
		Metrics:       map[string]GlyphMetrics{},
	}

	var buf sfnt.Buffer
	var missing []string
	for _, r := range Charset {
		if idx, err := parsed.GlyphIndex(&buf, r); err != nil || idx == 0 {
			missing = append(missing, string(r))
			continue
		}

		canvas := image.NewNRGBA(image.Rect(0, 0, canvasW, canvasH))
		d := &font.Drawer{
			Dst:  canvas,
			Src:  image.NewUniform(color.NRGBA{0, 0, 0, 255}),
			Face: face,
			Dot:  fixed.P(originX, originY),
		}
		advance := d.MeasureString(string(r))
		d.DrawString(string(r))

		trimmed, rect := trimAlpha(canvas, opts.Padding)
		if rect.Empty() {
			// Font has a glyph slot but draws nothing (e.g. a blank symbol).
			missing = append(missing, string(r))
			continue
		}

		filename := CharToFilename(r) + ".png"
		if err := savePNG(trimmed, filepath.Join(opts.OutputDir, filename)); err != nil {
			return fmt.Errorf("saving %s: %w", filename, err)
		}

		manifest.Glyphs[string(r)] = filename
		manifest.Metrics[string(r)] = GlyphMetrics{
			Width:    rect.Dx(),
			Height:   rect.Dy(),
			Baseline: originY - rect.Min.Y,
			Advance:  advance.Round(),
			Bearing:  rect.Min.X - originX,
		}
	}

	jsonData, err := json.MarshalIndent(manifest, "", "  ")
	if err != nil {
		return err
	}
	if err := os.WriteFile(filepath.Join(opts.OutputDir, "glyphs.json"), jsonData, 0644); err != nil {
		return err
	}

	fmt.Printf("%s: %d glyphs written to %s", opts.ID, len(manifest.Glyphs), opts.OutputDir)
	if len(missing) > 0 {
		fmt.Printf(" (missing %d: %s)", len(missing), strings.Join(missing, " "))
	}
	fmt.Println()
	return nil
}

// trimAlpha crops an NRGBA image to the bounding box of its non-transparent
// pixels plus padding. The returned rectangle is in source coordinates.
func trimAlpha(src *image.NRGBA, padding int) (*image.NRGBA, image.Rectangle) {
	b := src.Bounds()
	minX, minY := b.Max.X, b.Max.Y
	maxX, maxY := b.Min.X-1, b.Min.Y-1
	for y := b.Min.Y; y < b.Max.Y; y++ {
		row := src.Pix[(y-b.Min.Y)*src.Stride:]
		for x := b.Min.X; x < b.Max.X; x++ {
			if row[(x-b.Min.X)*4+3] == 0 {
				continue
			}
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
	if maxX < minX || maxY < minY {
		return src, image.Rectangle{}
	}
	rect := image.Rect(
		max(b.Min.X, minX-padding),
		max(b.Min.Y, minY-padding),
		min(b.Max.X, maxX+padding+1),
		min(b.Max.Y, maxY+padding+1),
	)
	dst := image.NewNRGBA(image.Rect(0, 0, rect.Dx(), rect.Dy()))
	draw.Draw(dst, dst.Bounds(), src, rect.Min, draw.Src)
	return dst, rect
}

// runFontSet parses `fontset` sub-command flags and generates the sheet.
func runFontSet(args []string) error {
	opts := DefaultFontSetOptions()
	fs := flag.NewFlagSet("fontset", flag.ContinueOnError)
	fs.StringVar(&opts.FontPath, "font", "", "Path to a .ttf/.otf font file (required)")
	fs.StringVar(&opts.OutputDir, "output", "", "Output directory for PNGs and glyphs.json (required unless -check)")
	fs.StringVar(&opts.ID, "id", "", "Sheet id (ASCII, used as directory name); defaults to font file name")
	fs.StringVar(&opts.Name, "name", "", "Human readable sheet name; defaults to id")
	fs.StringVar(&opts.License, "license", "", "License identifier stored in the manifest, e.g. OFL-1.1")
	fs.StringVar(&opts.Attribution, "attribution", "", "Attribution / copyright line stored in the manifest")
	fs.IntVar(&opts.DPI, "dpi", opts.DPI, "Raster DPI (matches the paper template pipeline)")
	fs.Float64Var(&opts.EmRatio, "em-ratio", opts.EmRatio, "Font em size as a fraction of the cell height")
	check := fs.Bool("check", false, "Only report which Charset runes the font is missing")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if opts.FontPath == "" {
		fs.Usage()
		return fmt.Errorf("-font is required")
	}
	if opts.ID == "" {
		base := filepath.Base(opts.FontPath)
		opts.ID = strings.ToLower(strings.TrimSuffix(base, filepath.Ext(base)))
	}
	if opts.Name == "" {
		opts.Name = opts.ID
	}
	if *check {
		return checkFontCoverage(opts.FontPath)
	}
	if opts.OutputDir == "" {
		fs.Usage()
		return fmt.Errorf("-output is required")
	}
	return generateFontSet(opts)
}

// checkFontCoverage prints which Charset runes a font cannot render.
func checkFontCoverage(fontPath string) error {
	data, err := os.ReadFile(fontPath)
	if err != nil {
		return err
	}
	parsed, err := opentype.Parse(data)
	if err != nil {
		return err
	}
	var buf sfnt.Buffer
	var missing []string
	for _, r := range Charset {
		if idx, err := parsed.GlyphIndex(&buf, r); err != nil || idx == 0 {
			missing = append(missing, string(r))
		}
	}
	fmt.Printf("%s: %d/%d covered", filepath.Base(fontPath), len(Charset)-len(missing), len(Charset))
	if len(missing) > 0 {
		fmt.Printf(", missing: %s", strings.Join(missing, " "))
	}
	fmt.Println()
	return nil
}

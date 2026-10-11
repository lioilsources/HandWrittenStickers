package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"path/filepath"
	"strings"

	xdraw "golang.org/x/image/draw"
	"golang.org/x/text/unicode/norm"
)

// runPreview renders a sheet the way the app lays it out: a contact sheet of
// every glyph (and variant) on a baseline guide, plus sample text. It is the
// quality check of plan M6 and works for any manifest version.
func runPreview(args []string) error {
	fs := flag.NewFlagSet("preview", flag.ContinueOnError)
	var out, text, bg string
	var cell int
	fs.StringVar(&out, "out", "preview.png", "Output PNG")
	fs.IntVar(&cell, "cell", 64, "Height in px of one template cell in the preview")
	fs.StringVar(&text, "text", "Příliš žluťoučký kůň úpěl ďábelské ódy.\nPŘÍLIŠ ŽLUŤOUČKÝ KŮŇ, 0123456789!?", "Sample text (\\n = new line)")
	fs.StringVar(&bg, "bg", "#fffdf5", "Background colour")
	fs.Usage = func() {
		fmt.Println("Usage: glyph_extractor preview <sheet_dir> [-out preview.png] [-cell 64] [-text ...]")
		fs.PrintDefaults()
	}
	if err := fs.Parse(positionalLast(args)); err != nil {
		return err
	}
	if fs.NArg() != 1 {
		fs.Usage()
		return fmt.Errorf("expected a sheet directory")
	}
	bgc, err := ParseHexColor(bg)
	if err != nil {
		return err
	}
	return renderPreview(fs.Arg(0), out, strings.ReplaceAll(text, `\n`, "\n"), cell, bgc)
}

type previewGlyph struct {
	img *image.NRGBA
	m   GlyphMetrics
	has bool // metrics available
}

func renderPreview(dir, out, text string, cell int, bg color.NRGBA) error {
	m, err := ReadManifest(dir)
	if err != nil {
		return err
	}
	dpi := m.DPI
	if dpi == 0 {
		dpi = 300
	}
	cellH := float64(GridConfig{CellHeightMM: m.CellSize.Height, DPI: dpi}.CellHeightPx())
	if m.CellSize.Height == 0 {
		cellH = float64(templateCellHeightPx(dpi))
	}
	baselineRatio := m.BaselineRatio
	if baselineRatio == 0 {
		baselineRatio = 0.75
	}
	scale := float64(cell) / cellH

	cache := map[string]previewGlyph{}
	load := func(key string, variant int) (previewGlyph, bool) {
		files := m.Glyphs[key]
		if len(files) == 0 {
			return previewGlyph{}, false
		}
		variant %= len(files)
		ck := fmt.Sprintf("%s#%d", key, variant)
		if g, ok := cache[ck]; ok {
			return g, true
		}
		img, err := loadImage(filepath.Join(dir, files[variant]))
		if err != nil {
			return previewGlyph{}, false
		}
		g := previewGlyph{img: toNRGBA(img)}
		if ms := m.Metrics[key]; variant < len(ms) {
			g.m, g.has = ms[variant], true
		}
		cache[ck] = g
		return g, true
	}

	// Contact sheet: every character and variant, 16 per row.
	type item struct {
		key     string
		variant int
	}
	var items []item
	seen := map[string]bool{}
	var keys []string
	for _, r := range Charset {
		keys = append(keys, string(r))
	}
	for k := range m.Glyphs {
		keys = append(keys, k)
	}
	for _, k := range keys {
		if seen[k] {
			continue
		}
		seen[k] = true
		for v := range m.Glyphs[k] {
			items = append(items, item{k, v})
		}
	}
	const perRow = 16
	colW := cell
	gridRows := (len(items) + perRow - 1) / perRow
	lines := strings.Split(text, "\n")
	textW := cell * 24
	width := max(perRow*colW, textW) + cell
	height := gridRows*cell + len(lines)*cell*6/5 + cell
	canvas := image.NewNRGBA(image.Rect(0, 0, width, height))
	draw.Draw(canvas, canvas.Bounds(), image.NewUniform(bg), image.Point{}, draw.Src)
	guide := color.NRGBA{150, 180, 255, 255}
	cellLine := color.NRGBA{225, 225, 225, 255}

	blit := func(g previewGlyph, x, y float64, s float64) {
		b := g.img.Bounds()
		w, h := int(float64(b.Dx())*s+0.5), int(float64(b.Dy())*s+0.5)
		if w < 1 || h < 1 {
			return
		}
		dst := image.Rect(int(x), int(y), int(x)+w, int(y)+h)
		xdraw.CatmullRom.Scale(canvas, dst, g.img, b, xdraw.Over, nil)
	}

	pad := cell / 2
	for i, it := range items {
		x0 := pad + (i%perRow)*colW
		y0 := pad/2 + (i/perRow)*cell
		hline(canvas, x0, x0+colW-2, y0, cellLine)
		baseY := y0 + int(float64(cell)*baselineRatio)
		hline(canvas, x0, x0+colW-2, baseY, guide)
		g, ok := load(it.key, it.variant)
		if !ok {
			continue
		}
		if g.has {
			w := float64(g.m.Width) * scale
			blit(g, float64(x0)+(float64(colW)-w)/2, float64(baseY)-float64(g.m.Baseline)*scale, scale)
		} else {
			s := float64(cell) / float64(g.img.Bounds().Dy())
			blit(g, float64(x0), float64(y0), s)
		}
	}

	// Sample text laid out like GlyphRenderer (variants cycle per character).
	y := float64(pad/2 + gridRows*cell + cell/4)
	used := map[string]int{}
	for _, line := range lines {
		x := float64(pad)
		baseY := y + float64(cell)*baselineRatio
		hline(canvas, pad, width-pad, int(baseY), guide)
		for _, r := range norm.NFC.String(line) {
			ch := string(r)
			if ch == " " {
				x += float64(cell) * 0.5
				continue
			}
			g, ok := load(ch, used[ch])
			used[ch]++
			if !ok {
				x += float64(cell) * 0.5
				continue
			}
			if g.has {
				blit(g, x+float64(g.m.Bearing)*scale, baseY-float64(g.m.Baseline)*scale, scale)
				x += float64(g.m.Advance) * scale
			} else {
				s := float64(cell) / float64(g.img.Bounds().Dy())
				blit(g, x, y, s)
				x += float64(g.img.Bounds().Dx()) * s
			}
		}
		y += float64(cell) * 6 / 5
	}
	if err := savePNG(canvas, out); err != nil {
		return err
	}
	fmt.Printf("Preview → %s (%d glyph images)\n", out, len(items))
	return nil
}

func hline(img *image.NRGBA, x0, x1, y int, c color.NRGBA) {
	if y < 0 || y >= img.Bounds().Dy() {
		return
	}
	for x := max(0, x0); x < min(img.Bounds().Dx(), x1); x++ {
		img.SetNRGBA(x, y, c)
	}
}

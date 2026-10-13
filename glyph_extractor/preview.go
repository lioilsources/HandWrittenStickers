package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"math"
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
	var marks bool
	fs.BoolVar(&marks, "marks", false, "Mark the entry (green) and exit (red) join points of each letter")
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
	return renderPreview(fs.Arg(0), out, strings.ReplaceAll(text, `\n`, "\n"), cell, bgc, marks)
}

type previewGlyph struct {
	img *image.NRGBA
	m   GlyphMetrics
	has bool // metrics available
}

func renderPreview(dir, out, text string, cell int, bg color.NRGBA, marks bool) error {
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
			gx, gy := float64(x0)+(float64(colW)-w)/2, float64(baseY)-float64(g.m.Baseline)*scale
			blit(g, gx, gy, scale)
			if marks {
				r := math.Max(1.5, float64(cell)/40)
				if p := g.m.Entry; p != nil {
					fillDisc(canvas, gx+float64(p[0])*scale, gy+float64(p[1])*scale, r, color.NRGBA{0, 160, 60, 255})
				}
				if p := g.m.Exit; p != nil {
					fillDisc(canvas, gx+float64(p[0])*scale, gy+float64(p[1])*scale, r, color.NRGBA{220, 30, 30, 255})
				}
			}
		} else {
			s := float64(cell) / float64(g.img.Bounds().Dy())
			blit(g, float64(x0), float64(y0), s)
		}
	}

	// Sample text laid out like GlyphRenderer (variants cycle per character).
	ink := color.NRGBA{20, 20, 20, 255}
	if c, err := ParseHexColor(m.InkColor); err == nil {
		ink = c
	}
	y := float64(pad/2 + gridRows*cell + cell/4)
	used := map[string]int{}
	for _, line := range lines {
		x := float64(pad)
		baseY := y + float64(cell)*baselineRatio
		hline(canvas, pad, width-pad, int(baseY), guide)
		// Joined sheets connect letters inside a word the way GlyphRenderer
		// does: the entry point lands a little right of the previous exit
		// and a pen-wide curve bridges the rest.
		var prev *previewGlyph
		var prevX, prevY float64 // top-left of the previous glyph image
		for _, r := range norm.NFC.String(line) {
			ch := string(r)
			if ch == " " {
				x += float64(cell) * 0.5
				prev = nil
				continue
			}
			g, ok := load(ch, used[ch])
			used[ch]++
			if !ok {
				x += float64(cell) * 0.5
				prev = nil
				continue
			}
			if g.has {
				gx, gy := x+float64(g.m.Bearing)*scale, baseY-float64(g.m.Baseline)*scale
				if prev != nil && prev.m.Exit != nil && g.m.Entry != nil && m.StrokeWidth > 0 {
					ex := prevX + float64(prev.m.Exit[0])*scale
					ey := prevY + float64(prev.m.Exit[1])*scale
					ny := gy + float64(g.m.Entry[1])*scale
					nx := ex + JoinGap(m.XHeight*scale, ny-ey)
					gx = nx - float64(g.m.Entry[0])*scale
					drawJoin(canvas, ex, ey, float64(prev.m.Exit[2]), nx, ny, float64(g.m.Entry[2]),
						m.StrokeWidth*scale, ink)
				}
				blit(g, gx, gy, scale)
				x = gx + float64(g.m.Advance-g.m.Bearing)*scale
				gc := g
				prev, prevX, prevY = &gc, gx, gy
			} else {
				s := float64(cell) / float64(g.img.Bounds().Dy())
				blit(g, x, y, s)
				x += float64(g.img.Bounds().Dx()) * s
				prev = nil
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

// JoinGap is the horizontal distance between the exit point of a letter and
// the entry point of the next: a fixed bit of the x-height plus room for the
// joining stroke to climb or drop dy. GlyphRenderer (Dart) uses the same rule.
func JoinGap(xHeight, dy float64) float64 {
	return 0.10*xHeight + 0.4*math.Abs(dy)
}

// joinCurve returns the cubic Bézier control points of the stroke from
// (x0,y0), leaving in direction d0, to (x1,y1), arriving in direction d1
// (degrees, 0 = right, 90 = up). Directions pointing backwards are pulled
// forward so the stroke never loops.
func joinCurve(x0, y0, d0, x1, y1, d1 float64) [4][2]float64 {
	l := math.Hypot(x1-x0, y1-y0) / 3
	dir := func(deg float64) (float64, float64) {
		deg = math.Max(-75, math.Min(75, deg))
		r := deg * math.Pi / 180
		return math.Cos(r), -math.Sin(r)
	}
	ax, ay := dir(d0)
	bx, by := dir(d1)
	return [4][2]float64{{x0, y0}, {x0 + ax*l, y0 + ay*l}, {x1 - bx*l, y1 - by*l}, {x1, y1}}
}

// drawJoin strokes the join curve with a round pen of the given width.
func drawJoin(img *image.NRGBA, x0, y0, d0, x1, y1, d1, width float64, c color.NRGBA) {
	if math.Hypot(x1-x0, y1-y0) < 0.5*width {
		return
	}
	p := joinCurve(x0, y0, d0, x1, y1, d1)
	n := int(math.Hypot(x1-x0, y1-y0)*2) + 2
	for i := 0; i <= n; i++ {
		t := float64(i) / float64(n)
		u := 1 - t
		x := u*u*u*p[0][0] + 3*u*u*t*p[1][0] + 3*u*t*t*p[2][0] + t*t*t*p[3][0]
		y := u*u*u*p[0][1] + 3*u*u*t*p[1][1] + 3*u*t*t*p[2][1] + t*t*t*p[3][1]
		fillDisc(img, x, y, width/2, c)
	}
}

// fillDisc paints an anti-aliased disc.
func fillDisc(img *image.NRGBA, cx, cy, r float64, c color.NRGBA) {
	b := img.Bounds()
	for y := int(cy - r - 1); y <= int(cy+r+1); y++ {
		for x := int(cx - r - 1); x <= int(cx+r+1); x++ {
			if x < b.Min.X || y < b.Min.Y || x >= b.Max.X || y >= b.Max.Y {
				continue
			}
			a := r - math.Hypot(float64(x)+0.5-cx, float64(y)+0.5-cy) + 0.5
			if a <= 0 {
				continue
			}
			a = math.Min(a, 1)
			o := img.NRGBAAt(x, y)
			mix := func(dst, src uint8) uint8 { return uint8(float64(dst)*(1-a) + float64(src)*a + 0.5) }
			img.SetNRGBA(x, y, color.NRGBA{mix(o.R, c.R), mix(o.G, c.G), mix(o.B, c.B), 255})
		}
	}
}

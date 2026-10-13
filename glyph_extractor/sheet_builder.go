package main

import (
	"fmt"
	"image"
	"image/draw"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"unicode"
	"unicode/utf8"

	xdraw "golang.org/x/image/draw"
)

// CellOptions controls how one template cell becomes a trimmed glyph.
type CellOptions struct {
	Key KeyOptions
	// Padding in px kept around the ink after trimming.
	Padding int
	// MinComponent is the smallest connected ink area (px) that is kept;
	// smaller blobs are scan noise. 0 = derived from the cell size.
	MinComponent int
}

func DefaultCellOptions() CellOptions {
	return CellOptions{Key: DefaultKeyOptions(), Padding: 2}
}

// ProcessCell keys the background of a cell and crops it to its ink.
//
// Ink is every pixel with alpha ≥ Key.TrimAlphaThreshold(). Connected ink
// blobs smaller than MinComponent (JPEG noise, dust) and thin blobs touching
// the cell edge (printed grid lines of a slightly misaligned scan) are
// ignored and cleared. rect is the crop in cell coordinates; ok is false for
// an empty cell.
func ProcessCell(cell image.Image, opts CellOptions) (glyph *image.NRGBA, rect image.Rectangle, ok bool) {
	keyed := Key(cell, opts.Key)
	b := keyed.Bounds()
	w, h := b.Dx(), b.Dy()
	thr := opts.Key.TrimAlphaThreshold()

	minArea := opts.MinComponent
	if minArea <= 0 {
		minArea = max(12, w*h/4000)
	}
	lineWidth := max(3, min(w, h)*3/100)

	clearEdgeLines(keyed, thr, lineWidth)
	labels, comps := connectedComponents(keyed, thr)
	keep := make([]bool, len(comps))
	ink := image.Rectangle{}
	for i, c := range comps {
		if c.area < minArea {
			continue
		}
		cb := c.bounds
		touchesEdge := cb.Min.X == 0 || cb.Min.Y == 0 || cb.Max.X == w || cb.Max.Y == h
		if touchesEdge && (cb.Dx() <= lineWidth || cb.Dy() <= lineWidth) {
			continue
		}
		keep[i] = true
		ink = ink.Union(cb)
	}
	if ink.Empty() {
		return nil, image.Rectangle{}, false
	}

	// Clear ignored blobs that fall inside the crop.
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			if l := labels[y*w+x]; l > 0 && !keep[l-1] {
				keyed.Pix[y*keyed.Stride+x*4+3] = 0
			}
		}
	}

	rect = image.Rect(
		max(0, ink.Min.X-opts.Padding), max(0, ink.Min.Y-opts.Padding),
		min(w, ink.Max.X+opts.Padding), min(h, ink.Max.Y+opts.Padding),
	)
	out := image.NewNRGBA(image.Rect(0, 0, rect.Dx(), rect.Dy()))
	draw.Draw(out, out.Bounds(), keyed, rect.Min.Add(b.Min), draw.Src)
	return out, rect, true
}

// clearEdgeLines erases printed grid lines along the cell border: rows (and
// columns) within band px of an edge whose ink covers more than half the
// cell width (height). Lines meeting at a corner form one big component, so
// this must happen before the component filter.
func clearEdgeLines(img *image.NRGBA, thr uint8, band int) {
	b := img.Bounds()
	w, h := b.Dx(), b.Dy()
	ink := func(x, y int) bool { return img.Pix[y*img.Stride+x*4+3] >= thr }
	clear := func(x, y int) { img.Pix[y*img.Stride+x*4+3] = 0 }
	for y := 0; y < h; y++ {
		if y >= band && y < h-band {
			continue
		}
		n := 0
		for x := 0; x < w; x++ {
			if ink(x, y) {
				n++
			}
		}
		if n > w/2 {
			for x := 0; x < w; x++ {
				clear(x, y)
			}
		}
	}
	for x := 0; x < w; x++ {
		if x >= band && x < w-band {
			continue
		}
		n := 0
		for y := 0; y < h; y++ {
			if ink(x, y) {
				n++
			}
		}
		if n > h/2 {
			for y := 0; y < h; y++ {
				clear(x, y)
			}
		}
	}
}

type component struct {
	area   int
	bounds image.Rectangle // in image-local coordinates (0,0 = top-left)
}

// connectedComponents labels 8-connected pixels with alpha ≥ thr. labels[i]
// is 0 for background and component index+1 otherwise.
func connectedComponents(img *image.NRGBA, thr uint8) ([]int32, []component) {
	b := img.Bounds()
	w, h := b.Dx(), b.Dy()
	labels := make([]int32, w*h)
	var comps []component
	stack := make([]int, 0, 1024)
	isInk := func(x, y int) bool { return img.Pix[y*img.Stride+x*4+3] >= thr && thr > 0 }
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			if labels[y*w+x] != 0 || !isInk(x, y) {
				continue
			}
			id := int32(len(comps) + 1)
			c := component{bounds: image.Rect(x, y, x+1, y+1)}
			labels[y*w+x] = id
			stack = append(stack[:0], y*w+x)
			for len(stack) > 0 {
				p := stack[len(stack)-1]
				stack = stack[:len(stack)-1]
				px, py := p%w, p/w
				c.area++
				c.bounds = c.bounds.Union(image.Rect(px, py, px+1, py+1))
				for dy := -1; dy <= 1; dy++ {
					for dx := -1; dx <= 1; dx++ {
						nx, ny := px+dx, py+dy
						if nx < 0 || ny < 0 || nx >= w || ny >= h || labels[ny*w+nx] != 0 || !isInk(nx, ny) {
							continue
						}
						labels[ny*w+nx] = id
						stack = append(stack, ny*w+nx)
					}
				}
			}
			comps = append(comps, c)
		}
	}
	return labels, comps
}

// SheetGlyph is one glyph image waiting to be written by SheetBuilder.
type SheetGlyph struct {
	Key     string // character (or accent key such as "caron")
	Image   *image.NRGBA
	Metrics GlyphMetrics
	// Row is the template row (page*Rows + row) the glyph was cut from, or
	// -1 when it does not come from a template grid.
	Row int
}

// SheetBuilder collects glyphs (possibly several variants per character),
// normalises their size and writes PNGs plus glyphs.json.
type SheetBuilder struct {
	Manifest *ManifestV2
	glyphs   []SheetGlyph
	// Set by PrepareJoins, in the same pixel units as the glyph images.
	xHeight, slantDeg, strokeWidth float64
	inkColor                       string
}

// NewSheetBuilder prepares a sheet with the template geometry at dpi.
func NewSheetBuilder(id, name, source string, dpi int) *SheetBuilder {
	m := NewManifest(id, name, source, dpi)
	m.EmHeight = int(float64(templateCellHeightPx(dpi))*0.62 + 0.5)
	return &SheetBuilder{Manifest: m}
}

// templateCellHeightPx is the 26.2 mm template cell height at dpi.
func templateCellHeightPx(dpi int) int {
	return GridConfig{CellHeightMM: 26.2, DPI: dpi}.CellHeightPx()
}

// SideBearingPx is the default side bearing for scanned glyphs: 4 % of the em
// (fonts typically use 3–6 %), so neighbouring letters do not touch.
func (sb *SheetBuilder) SideBearingPx() int {
	return max(2, sb.Manifest.EmHeight*4/100)
}

// Add queues one glyph variant.
func (sb *SheetBuilder) Add(g SheetGlyph) { sb.glyphs = append(sb.glyphs, g) }

// Len returns the number of queued glyph images.
func (sb *SheetBuilder) Len() int { return len(sb.glyphs) }

// CellMetrics derives metrics for a glyph cropped at rect out of a template
// cell whose baseline lies at baselineY (cell coordinates). Advance and
// bearing are left 0 and filled in by Write with the sheet's side bearing,
// so they do not depend on size normalisation.
func CellMetrics(rect image.Rectangle, baselineY int) GlyphMetrics {
	return GlyphMetrics{
		Width:    rect.Dx(),
		Height:   rect.Dy(),
		Baseline: baselineY - rect.Min.Y,
	}
}

// sitsOnBaseline reports whether a character's ink normally ends on the
// baseline, so its bottom edge can be used to locate the written baseline.
func sitsOnBaseline(key string) bool {
	r, size := utf8.DecodeRuneInString(key)
	if size != len(key) {
		return false
	}
	if strings.ContainsRune("gjpqyýfJQ", r) {
		return false
	}
	return unicode.IsLetter(r) || unicode.IsDigit(r)
}

// FitRowBaselines replaces the template baseline guide with the baseline
// the writer actually used. For every template row it takes the median ink
// bottom of letters and digits that sit on the baseline, fits a line through
// those per-row offsets for each page (a shifted or slightly rotated scan
// gives a smooth trend), and moves every glyph's baseline by the fitted
// offset of its row. Rows without such characters (punctuation) follow the
// fit. Returns the per-page fitted offsets for logging.
func (sb *SheetBuilder) FitRowBaselines(rowsPerPage, padding int) []string {
	type sample struct{ row, off int }
	perRow := map[int][]int{}
	for _, g := range sb.glyphs {
		if g.Row < 0 || !sitsOnBaseline(g.Key) {
			continue
		}
		// Ink bottom relative to the template baseline (padding excluded).
		bottom := g.Metrics.Height - padding
		perRow[g.Row] = append(perRow[g.Row], bottom-g.Metrics.Baseline)
	}
	fits := map[int][2]float64{} // page → (a, b): offset = a + b*rowInPage
	var log []string
	pages := map[int][]sample{}
	for row, offs := range perRow {
		if len(offs) >= 3 {
			pages[row/rowsPerPage] = append(pages[row/rowsPerPage], sample{row % rowsPerPage, median(offs)})
		}
	}
	for page, ss := range pages {
		var a, b float64
		if len(ss) == 1 {
			a = float64(ss[0].off)
		} else {
			var sx, sy, sxx, sxy float64
			n := float64(len(ss))
			for _, s := range ss {
				sx += float64(s.row)
				sy += float64(s.off)
				sxx += float64(s.row * s.row)
				sxy += float64(s.row * s.off)
			}
			if d := n*sxx - sx*sx; d != 0 {
				b = (n*sxy - sx*sy) / d
			}
			a = (sy - b*sx) / n
		}
		fits[page] = [2]float64{a, b}
		log = append(log, fmt.Sprintf("page %d: baseline offset %+.1f px %+.2f px/row (%d rows)", page+1, a, b, len(ss)))
	}
	for i, g := range sb.glyphs {
		if g.Row < 0 {
			continue
		}
		f, ok := fits[g.Row/rowsPerPage]
		if !ok {
			continue
		}
		off := f[0] + f[1]*float64(g.Row%rowsPerPage)
		sb.glyphs[i].Metrics.Baseline += int(off + 0.5*sign(off))
	}
	sort.Strings(log)
	return log
}

func sign(v float64) float64 {
	if v < 0 {
		return -1
	}
	return 1
}

// NormalizeCapHeight rescales all glyphs so that the ink height of the
// reference character (normally "H") is capRatio × emHeight, the same rule
// fontset applies to fonts. padding is the transparent border included in
// each glyph image. Returns the applied scale (1 when nothing was done).
func (sb *SheetBuilder) NormalizeCapHeight(capRatio float64, padding int, refs ...string) float64 {
	if capRatio <= 0 {
		return 1
	}
	var inkH int
	for _, ref := range refs {
		var hs []int
		for _, g := range sb.glyphs {
			if g.Key == ref {
				hs = append(hs, g.Metrics.Height-2*padding)
			}
		}
		if len(hs) > 0 {
			inkH = median(hs)
			break
		}
	}
	if inkH <= 0 {
		return 1
	}
	s := capRatio * float64(sb.Manifest.EmHeight) / float64(inkH)
	sb.Scale(s)
	return s
}

// Scale resamples every glyph image and its metrics by s.
func (sb *SheetBuilder) Scale(s float64) {
	if s > 0.995 && s < 1.005 {
		return
	}
	sb.xHeight *= s
	sb.strokeWidth *= s
	for i, g := range sb.glyphs {
		b := g.Image.Bounds()
		nw := max(1, int(float64(b.Dx())*s+0.5))
		nh := max(1, int(float64(b.Dy())*s+0.5))
		dst := image.NewNRGBA(image.Rect(0, 0, nw, nh))
		xdraw.CatmullRom.Scale(dst, dst.Bounds(), g.Image, b, xdraw.Src, nil)
		m := g.Metrics.Scaled(s)
		m.Width, m.Height = nw, nh
		g.Image, g.Metrics = dst, m
		sb.glyphs[i] = g
	}
}

// Write saves all glyph PNGs and glyphs.json into dir.
func (sb *SheetBuilder) Write(dir string) error {
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}
	counts := map[string]int{}
	for _, g := range sb.glyphs {
		base := glyphFileBase(g.Key)
		file := VariantFilename(base, counts[g.Key])
		counts[g.Key]++
		m := g.Metrics
		if m.Advance == 0 {
			sbPx := sb.SideBearingPx()
			m.Bearing = sbPx
			m.Advance = m.Width + 2*sbPx
		}
		if err := savePNG(g.Image, filepath.Join(dir, file)); err != nil {
			return fmt.Errorf("saving %s: %w", file, err)
		}
		sb.Manifest.Add(g.Key, file, m)
	}
	round1 := func(v float64) float64 { return float64(int(v*10+0.5)) / 10 }
	sb.Manifest.XHeight = round1(sb.xHeight)
	sb.Manifest.SlantDeg = float64(int(sb.slantDeg*10+0.5*sign(sb.slantDeg))) / 10
	sb.Manifest.StrokeWidth = round1(sb.strokeWidth)
	sb.Manifest.InkColor = sb.inkColor
	return sb.Manifest.Write(dir)
}

// Summary lists characters of Charset missing from the sheet.
func (sb *SheetBuilder) Summary() string {
	have := map[string]int{}
	for _, g := range sb.glyphs {
		have[g.Key]++
	}
	var missing []string
	for _, r := range Charset {
		if have[string(r)] == 0 {
			missing = append(missing, string(r))
		}
	}
	variants := 0
	for _, n := range have {
		if n > 1 {
			variants++
		}
	}
	s := fmt.Sprintf("%d glyph images, %d characters (%d with variants)", len(sb.glyphs), len(have), variants)
	if len(missing) > 0 {
		sort.Strings(missing)
		s += fmt.Sprintf(", missing %d: %s", len(missing), strings.Join(missing, " "))
	}
	return s
}

// glyphFileBase maps a manifest key to an ASCII file name stem.
func glyphFileBase(key string) string {
	if key == "ı" {
		return "dotlessi"
	}
	if r, size := utf8.DecodeRuneInString(key); size == len(key) && r != utf8.RuneError {
		return CharToFilename(r)
	}
	return key
}

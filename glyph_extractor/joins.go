package main

import (
	"fmt"
	"image"
	"math"
	"sort"
	"unicode"
	"unicode/utf8"

	xdraw "golang.org/x/image/draw"
	"golang.org/x/image/math/f64"
	"golang.org/x/text/unicode/norm"
)

// JoinOptions selects what PrepareJoins does to a sheet of letters that were
// written one per template cell and should read as joined handwriting.
type JoinOptions struct {
	// Joins stores entry/exit points of the pen stroke so the renderer can
	// connect neighbouring letters.
	Joins bool
	// FixSlant shears letters whose slant strays from the sheet's median.
	FixSlant bool
	// FixXHeight rescales lowercase letters whose body height strays from
	// the sheet's median.
	FixXHeight bool
	// SnapBaseline puts lowercase letters without descenders on the
	// baseline one by one instead of trusting the per-row fit.
	SnapBaseline bool
}

func (o JoinOptions) any() bool { return o.Joins || o.FixSlant || o.FixXHeight || o.SnapBaseline }

// Lowercase letters (by base letter, accents stripped) used as references.
const (
	xHeightLetters   = "aceimnorsuvwxz"       // body height = x-height
	baselineLetters  = "abcdehiklmnorstuvwxz" // ink ends on the baseline
	slantLetters     = "bdfhklt"              // long straight stroke: slant is well defined
	maxSlantFixDeg   = 10.0
	slantToleranceDg = 3.0
	xHeightTolerance = 0.08
	maxXHeightFix    = 0.15
)

// baseLetter returns the letter of key without its accent ('č' → 'c') and
// whether key is a single letter at all.
func baseLetter(key string) (rune, bool) {
	r, size := utf8.DecodeRuneInString(key)
	if size != len(key) || !unicode.IsLetter(r) {
		return 0, false
	}
	base, _ := utf8.DecodeRuneInString(norm.NFD.String(key))
	return base, true
}

func inSet(set string, r rune) bool {
	for _, s := range set {
		if s == r {
			return true
		}
	}
	return false
}

// body is the largest connected ink blob of a glyph: the letter without its
// accent or dot.
type body struct {
	w, h   int
	mask   []bool
	bounds image.Rectangle
	area   int
}

func (b body) at(x, y int) bool {
	return x >= 0 && y >= 0 && x < b.w && y < b.h && b.mask[y*b.w+x]
}

func glyphBody(img *image.NRGBA) body {
	labels, comps := connectedComponents(img, 128)
	bd := body{w: img.Bounds().Dx(), h: img.Bounds().Dy()}
	best := -1
	for i, c := range comps {
		if best < 0 || c.area > comps[best].area {
			best = i
		}
	}
	bd.mask = make([]bool, bd.w*bd.h)
	if best < 0 {
		return bd
	}
	for i, l := range labels {
		bd.mask[i] = l == int32(best+1)
	}
	bd.bounds, bd.area = comps[best].bounds, comps[best].area
	return bd
}

// thin reduces a mask to a one pixel wide skeleton (Zhang–Suen).
func thin(mask []bool, w, h int) []bool {
	sk := append([]bool(nil), mask...)
	at := func(x, y int) int {
		if x < 0 || y < 0 || x >= w || y >= h || !sk[y*w+x] {
			return 0
		}
		return 1
	}
	var drop []int
	for {
		changed := false
		for pass := 0; pass < 2; pass++ {
			drop = drop[:0]
			for y := 0; y < h; y++ {
				for x := 0; x < w; x++ {
					if !sk[y*w+x] {
						continue
					}
					p := [8]int{at(x, y-1), at(x+1, y-1), at(x+1, y), at(x+1, y+1),
						at(x, y+1), at(x-1, y+1), at(x-1, y), at(x-1, y-1)}
					n, trans := 0, 0
					for i := 0; i < 8; i++ {
						n += p[i]
						if p[i] == 0 && p[(i+1)%8] == 1 {
							trans++
						}
					}
					if n < 2 || n > 6 || trans != 1 {
						continue
					}
					if pass == 0 && (p[0]*p[2]*p[4] != 0 || p[2]*p[4]*p[6] != 0) {
						continue
					}
					if pass == 1 && (p[0]*p[2]*p[6] != 0 || p[0]*p[4]*p[6] != 0) {
						continue
					}
					drop = append(drop, y*w+x)
				}
			}
			for _, i := range drop {
				sk[i] = false
			}
			changed = changed || len(drop) > 0
		}
		if !changed {
			return sk
		}
	}
}

// strokeEnd is a loose end of the skeleton and the direction the stroke
// runs out of the letter there (unit vector, image coordinates).
type strokeEnd struct {
	x, y   int
	dx, dy float64
}

// strokeEnds finds skeleton pixels with a single neighbour. The direction
// is taken from the stretch of skeleton reach px behind the end.
func strokeEnds(sk []bool, w, h, reach int) []strokeEnd {
	on := func(x, y int) bool { return x >= 0 && y >= 0 && x < w && y < h && sk[y*w+x] }
	var ends []strokeEnd
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			if !sk[y*w+x] {
				continue
			}
			n := 0
			for dy := -1; dy <= 1; dy++ {
				for dx := -1; dx <= 1; dx++ {
					if (dx != 0 || dy != 0) && on(x+dx, y+dy) {
						n++
					}
				}
			}
			if n != 1 {
				continue
			}
			// Breadth-first walk back along the skeleton.
			dist := map[int]int{y*w + x: 0}
			frontier := []int{y*w + x}
			for d := 1; d <= reach && len(frontier) > 0; d++ {
				var next []int
				for _, p := range frontier {
					px, py := p%w, p/w
					for dy := -1; dy <= 1; dy++ {
						for dx := -1; dx <= 1; dx++ {
							q := (py+dy)*w + px + dx
							if !on(px+dx, py+dy) {
								continue
							}
							if _, seen := dist[q]; !seen {
								dist[q] = d
								next = append(next, q)
							}
						}
					}
				}
				if len(next) == 0 {
					break
				}
				frontier = next
			}
			var sx, sy float64
			for _, p := range frontier {
				sx += float64(p % w)
				sy += float64(p / w)
			}
			vx := float64(x) - sx/float64(len(frontier))
			vy := float64(y) - sy/float64(len(frontier))
			if l := math.Hypot(vx, vy); l > 0 {
				vx, vy = vx/l, vy/l
			}
			ends = append(ends, strokeEnd{x, y, vx, vy})
		}
	}
	return ends
}

// estimateSlant returns the slant of a letter in degrees (positive = top
// leaning right): the shear that makes its vertical strokes most upright,
// i.e. the column histogram most peaked.
func estimateSlant(b body, baseline int) float64 {
	best, bestScore := 0.0, -1.0
	hist := make([]int, b.w+2*b.h+4)
	for deg := -40; deg <= 40; deg++ {
		t := math.Tan(float64(deg) * math.Pi / 180)
		for i := range hist {
			hist[i] = 0
		}
		for y := b.bounds.Min.Y; y < b.bounds.Max.Y; y++ {
			shift := float64(baseline-y) * t
			for x := b.bounds.Min.X; x < b.bounds.Max.X; x++ {
				if b.mask[y*b.w+x] {
					i := int(math.Floor(float64(x)-shift+0.5)) + b.h + 2
					if i >= 0 && i < len(hist) {
						hist[i]++
					}
				}
			}
		}
		score := 0.0
		for _, v := range hist {
			score += float64(v) * float64(v)
		}
		if score > bestScore {
			best, bestScore = float64(deg), score
		}
	}
	return best
}

// alphaBounds returns the bounding box of pixels with alpha ≥ thr.
func alphaBounds(img *image.NRGBA, thr uint8) image.Rectangle {
	b := img.Bounds()
	r := image.Rectangle{}
	for y := 0; y < b.Dy(); y++ {
		for x := 0; x < b.Dx(); x++ {
			if img.Pix[y*img.Stride+x*4+3] >= thr {
				r = r.Union(image.Rect(x, y, x+1, y+1))
			}
		}
	}
	return r
}

// shearGlyph changes the slant of g by deltaDeg around its baseline, so the
// point where the letter meets the baseline stays where it was.
func shearGlyph(g SheetGlyph, deltaDeg float64, padding int) SheetGlyph {
	k := math.Tan(deltaDeg * math.Pi / 180)
	b := g.Image.Bounds()
	w, h, bl := b.Dx(), b.Dy(), float64(g.Metrics.Baseline)
	// A pixel at height (bl − y) above the baseline moves right by k·height.
	lo := math.Min(k*bl, k*(bl-float64(h)))
	hi := math.Max(k*bl, k*(bl-float64(h)))
	off := math.Ceil(-math.Min(lo, 0)) + 1
	dst := image.NewNRGBA(image.Rect(0, 0, w+int(math.Ceil(hi-math.Min(lo, 0)))+3, h))
	xdraw.CatmullRom.Transform(dst, f64.Aff3{1, -k, k*bl + off, 0, 1, 0}, g.Image, b, xdraw.Src, nil)
	ink := alphaBounds(dst, 24)
	if ink.Empty() {
		return g
	}
	crop := image.Rect(max(0, ink.Min.X-padding), max(0, ink.Min.Y-padding),
		min(dst.Bounds().Dx(), ink.Max.X+padding), min(h, ink.Max.Y+padding))
	out := image.NewNRGBA(image.Rect(0, 0, crop.Dx(), crop.Dy()))
	xdraw.Draw(out, out.Bounds(), dst, crop.Min, xdraw.Src)
	g.Image = out
	g.Metrics.Width, g.Metrics.Height = crop.Dx(), crop.Dy()
	g.Metrics.Baseline -= crop.Min.Y
	return g
}

// scaleGlyph resamples one glyph and its metrics by s.
func scaleGlyph(g SheetGlyph, s float64) SheetGlyph {
	b := g.Image.Bounds()
	nw := max(1, int(float64(b.Dx())*s+0.5))
	nh := max(1, int(float64(b.Dy())*s+0.5))
	dst := image.NewNRGBA(image.Rect(0, 0, nw, nh))
	xdraw.CatmullRom.Scale(dst, dst.Bounds(), g.Image, b, xdraw.Src, nil)
	m := g.Metrics.Scaled(s)
	m.Width, m.Height = nw, nh
	g.Image, g.Metrics = dst, m
	return g
}

func medianF(v []float64) float64 {
	if len(v) == 0 {
		return 0
	}
	s := append([]float64(nil), v...)
	sort.Float64s(s)
	if len(s)%2 == 1 {
		return s[len(s)/2]
	}
	return (s[len(s)/2-1] + s[len(s)/2]) / 2
}

// PrepareJoins evens out letters written one per cell and records where
// their strokes can be joined. Call it after FitRowBaselines and before
// NormalizeCapHeight, while the glyphs still have the scan's resolution.
// It returns lines for the log.
func (sb *SheetBuilder) PrepareJoins(o JoinOptions, padding int) []string {
	if !o.any() {
		return nil
	}
	var log []string
	lower := func(g SheetGlyph) (rune, bool) {
		base, ok := baseLetter(g.Key)
		r, _ := utf8.DecodeRuneInString(g.Key)
		return base, ok && unicode.IsLower(r)
	}
	measureX := func() float64 {
		var hs []float64
		for _, g := range sb.glyphs {
			if base, ok := lower(g); ok && inSet(xHeightLetters, base) {
				if bd := glyphBody(g.Image); bd.area > 0 {
					hs = append(hs, float64(g.Metrics.Baseline-bd.bounds.Min.Y))
				}
			}
		}
		return medianF(hs)
	}
	xh := measureX()
	if xh <= 0 {
		return []string{"joins: no lowercase letters to measure, skipped"}
	}

	if o.SnapBaseline {
		n := 0
		for i, g := range sb.glyphs {
			base, ok := lower(g)
			if !ok || !inSet(baselineLetters, base) {
				continue
			}
			bd := glyphBody(g.Image)
			if d := bd.bounds.Max.Y - g.Metrics.Baseline; d != 0 && math.Abs(float64(d)) <= 0.25*xh {
				sb.glyphs[i].Metrics.Baseline = bd.bounds.Max.Y
				n++
			}
		}
		xh = measureX()
		log = append(log, fmt.Sprintf("joins: %d letters moved onto the baseline", n))
	}

	// Slant: the median of letters with a long straight stroke.
	slantOf := map[int]float64{}
	var slants []float64
	for i, g := range sb.glyphs {
		if base, ok := lower(g); ok && inSet(slantLetters, base) {
			s := estimateSlant(glyphBody(g.Image), g.Metrics.Baseline)
			slantOf[i] = s
			slants = append(slants, s)
		}
	}
	sb.slantDeg = medianF(slants)
	if o.FixSlant && len(slants) >= 3 {
		n := 0
		for i, s := range slantOf {
			d := sb.slantDeg - s
			if math.Abs(d) <= slantToleranceDg {
				continue
			}
			d = math.Max(-maxSlantFixDeg, math.Min(maxSlantFixDeg, d))
			sb.glyphs[i] = shearGlyph(sb.glyphs[i], d, padding)
			n++
		}
		log = append(log, fmt.Sprintf("joins: slant %.1f°, %d letters sheared to it", sb.slantDeg, n))
	}

	if o.FixXHeight {
		n := 0
		for i, g := range sb.glyphs {
			base, ok := lower(g)
			if !ok || !inSet(xHeightLetters, base) {
				continue
			}
			bd := glyphBody(g.Image)
			h := float64(g.Metrics.Baseline - bd.bounds.Min.Y)
			if h <= 0 || math.Abs(h/xh-1) <= xHeightTolerance {
				continue
			}
			s := math.Max(1-maxXHeightFix, math.Min(1+maxXHeightFix, xh/h))
			sb.glyphs[i] = scaleGlyph(g, s)
			n++
		}
		log = append(log, fmt.Sprintf("joins: x-height %.0f px, %d letters rescaled to it", xh, n))
	}
	sb.xHeight = xh

	if o.Joins {
		var widths []float64
		type cand struct {
			i  int
			bd body
			sk []bool
		}
		var cands []cand
		for i, g := range sb.glyphs {
			if _, ok := baseLetter(g.Key); !ok {
				continue
			}
			bd := glyphBody(g.Image)
			if bd.area == 0 {
				continue
			}
			sk := thin(bd.mask, bd.w, bd.h)
			n := 0
			for _, v := range sk {
				if v {
					n++
				}
			}
			if n > 0 {
				widths = append(widths, float64(bd.area)/float64(n))
			}
			cands = append(cands, cand{i, bd, sk})
		}
		sb.strokeWidth = medianF(widths)
		// The pen's colour: fully opaque pixels of the letters.
		var sum [3]int
		n := 0
		for _, c := range cands {
			pix := sb.glyphs[c.i].Image.Pix
			for i := 0; i+3 < len(pix); i += 4 {
				if pix[i+3] == 255 {
					sum[0] += int(pix[i])
					sum[1] += int(pix[i+1])
					sum[2] += int(pix[i+2])
					n++
				}
			}
		}
		if n > 0 {
			sb.inkColor = fmt.Sprintf("#%02x%02x%02x", sum[0]/n, sum[1]/n, sum[2]/n)
		}
		entries, exits := 0, 0
		for _, c := range cands {
			g := &sb.glyphs[c.i]
			_, isLower := lower(*g)
			entry, exit := joinPoints(c.bd, c.sk, g.Metrics.Baseline, xh, sb.strokeWidth, isLower)
			g.Metrics.Entry, g.Metrics.Exit = entry, exit
			if entry != nil {
				entries++
			}
			if exit != nil {
				exits++
			}
		}
		log = append(log, fmt.Sprintf("joins: stroke %.1f px, %d entry and %d exit points on %d letters",
			sb.strokeWidth, entries, exits, len(cands)))
	}
	return log
}

// joinPoints picks the stroke ends where a letter joins its neighbours.
//
// Both lie in the band of lowercase bodies, from a little under the
// baseline to a little over the x-height: exit is the rightmost loose end
// in the right part of the letter, entry the leftmost one in the left part.
// Lowercase letters without such an end (an "a" starts on its oval, an "s"
// ends in a curl) join where their outline reaches furthest out in the
// band. Capitals only ever lead into the next letter, and only by a real
// stroke end.
func joinPoints(bd body, sk []bool, baseline int, xh, stroke float64, isLower bool) (entry, exit *JoinPoint) {
	top := float64(baseline) - 1.2*xh
	bottom := float64(baseline) + 0.15*xh
	inBand := func(y int) bool { return float64(y) >= top && float64(y) <= bottom }
	x0, bw := float64(bd.bounds.Min.X), float64(bd.bounds.Dx())
	deg := func(dx, dy float64) int {
		a := math.Atan2(-dy, dx) * 180 / math.Pi
		return int(math.Round(a))
	}
	reach := max(4, int(2.5*stroke+0.5))
	var in, out *strokeEnd
	ends := strokeEnds(sk, bd.w, bd.h, reach)
	for i := range ends {
		e := &ends[i]
		if !inBand(e.y) {
			continue
		}
		rel := (float64(e.x) - x0) / bw
		// The stroke leaves to the right and arrives from the left.
		if rel >= 0.6 && e.dx > 0.2 && (out == nil || e.x > out.x) {
			out = e
		}
		if rel <= 0.4 && e.dx < -0.2 && (in == nil || e.x < in.x) {
			in = e
		}
	}
	if out != nil {
		exit = &JoinPoint{out.x, out.y, deg(out.dx, out.dy)}
	}
	if !isLower {
		return nil, exit
	}
	if in != nil {
		// The pen travels into the letter: opposite of the outward direction.
		entry = &JoinPoint{in.x, in.y, deg(-in.dx, -in.dy)}
	}
	if entry != nil && exit != nil {
		return entry, exit
	}
	// Outline extremes inside the body band (baseline … x-height).
	bodyTop := float64(baseline) - xh
	left, right := image.Point{-1, 0}, image.Point{-1, 0}
	for y := 0; y < bd.h; y++ {
		if float64(y) < bodyTop || y > baseline {
			continue
		}
		for x := 0; x < bd.w; x++ {
			if !sk[y*bd.w+x] {
				continue
			}
			if left.X < 0 || x < left.X {
				left = image.Point{x, y}
			}
			if right.X < 0 || x > right.X {
				right = image.Point{x, y}
			}
		}
	}
	if entry == nil && left.X >= 0 {
		entry = &JoinPoint{left.X, left.Y, 0}
	}
	if exit == nil && right.X >= 0 {
		exit = &JoinPoint{right.X, right.Y, 0}
	}
	return entry, exit
}

package main

import (
	"image"
	"image/color"
	"math"
)

// DetectedGrid holds the printed grid lines found in a photo of a filled-in
// template. Lines may lean (perspective): vertical line i runs from
// (XTop[i], Top) to (XBottom[i], Bottom), horizontal line j from
// (Left, YLeft[j]) to (Right, YRight[j]).
type DetectedGrid struct {
	XTop, XBottom []float64
	YLeft, YRight []float64
}

// corner returns the intersection of vertical line c and horizontal line r.
func (g DetectedGrid) corner(c, r int, w, h float64) (float64, float64) {
	// Parametrise both lines and intersect; lines are near-axis-aligned so a
	// two-step fixed-point iteration is exact enough.
	y := (g.YLeft[r] + g.YRight[r]) / 2
	var x float64
	for i := 0; i < 3; i++ {
		x = g.XTop[c] + (g.XBottom[c]-g.XTop[c])*y/h
		y = g.YLeft[r] + (g.YRight[r]-g.YLeft[r])*x/w
	}
	return x, y
}

// DetectGrid finds cols+1 vertical and rows+1 horizontal evenly spaced grid
// lines in a photo or scan of the template. It works on a line-enhanced
// projection profile, evaluated separately for both halves of the image to
// capture mild perspective. ok is false when no convincing grid is found.
func DetectGrid(img image.Image, cols, rows int) (DetectedGrid, bool) {
	gray := toGray(img)
	w, h := gray.Bounds().Dx(), gray.Bounds().Dy()
	// Work on a ~1000 px image: thin lines survive, the search stays fast.
	step := max(1, max(w, h)/1400)
	vert := func(y0, y1 int) []float64 { return lineProfile(gray, true, y0, y1, step) }
	horz := func(x0, x1 int) []float64 { return lineProfile(gray, false, x0, x1, step) }

	xTop, ok1 := fitLines(vert(0, h/2), cols, step)
	xBot, ok2 := fitLines(vert(h/2, h), cols, step)
	yLeft, ok3 := fitLines(horz(0, w/2), rows, step)
	yRight, ok4 := fitLines(horz(w/2, w), rows, step)
	if !(ok1 && ok2 && ok3 && ok4) {
		return DetectedGrid{}, false
	}
	// The profiles were measured at the centres of the halves (¼ and ¾);
	// extrapolate to the image edges.
	extrap := func(a, b []float64) ([]float64, []float64) {
		lo := make([]float64, len(a))
		hi := make([]float64, len(a))
		for i := range a {
			d := (b[i] - a[i]) * 2 // change over half the image → full image
			lo[i] = a[i] - d/4
			hi[i] = b[i] + d/4
		}
		return lo, hi
	}
	g := DetectedGrid{}
	g.XTop, g.XBottom = extrap(xTop, xBot)
	g.YLeft, g.YRight = extrap(yLeft, yRight)
	return g, true
}

// lineProfile scores every column (vertical=true) or row for thin dark
// lines: a pixel counts when it is darker than both neighbours 5 px away
// across the line direction, which ignores paper shading and most ink blobs.
func lineProfile(g *image.Gray, vertical bool, from, to, step int) []float64 {
	w, h := g.Bounds().Dx(), g.Bounds().Dy()
	n := w
	if !vertical {
		n = h
	}
	d := max(3, 5*step/2)
	prof := make([]float64, n/step+1)
	at := func(x, y int) int { return int(g.Pix[y*g.Stride+x]) }
	for i := d; i < n-d; i += step {
		var s float64
		for j := from; j < to; j += step {
			var c, a, b int
			if vertical {
				c, a, b = at(i, j), at(i-d, j), at(i+d, j)
			} else {
				c, a, b = at(j, i), at(j, i-d), at(j, i+d)
			}
			if m := min(a, b) - c; m > 8 && m < 120 {
				s++
			}
		}
		prof[i/step] = s
	}
	// Light smoothing so a line 2–3 samples wide becomes one peak.
	sm := make([]float64, len(prof))
	for i := range prof {
		for k := -1; k <= 1; k++ {
			if j := i + k; j >= 0 && j < len(prof) {
				sm[i] += prof[j]
			}
		}
	}
	return sm
}

// fitLines finds n+1 equally spaced peaks in prof (sampled every step px)
// and refines each line to its local maximum. Returns positions in full
// resolution pixels.
func fitLines(prof []float64, n, step int) ([]float64, bool) {
	L := len(prof)
	best, bestS, bestO := -1.0, 0.0, 0.0
	var mean float64
	for _, v := range prof {
		mean += v
	}
	mean /= float64(L)
	for s := float64(L) / float64(n+6); s <= float64(L)/float64(n)*1.02; s += 0.25 {
		for o := 0.0; o+s*float64(n) < float64(L); o += 0.5 {
			var sum float64
			for k := 0; k <= n; k++ {
				i := int(o + s*float64(k) + 0.5)
				sum += prof[min(i, L-1)]
			}
			if sum > best {
				best, bestS, bestO = sum, s, o
			}
		}
	}
	// A real grid gives peaks well above the average column.
	if bestS == 0 || best/float64(n+1) < mean*2.5 {
		return nil, false
	}
	lines := make([]float64, n+1)
	win := int(math.Max(2, bestS/8))
	for k := 0; k <= n; k++ {
		c := int(bestO + bestS*float64(k) + 0.5)
		bi, bv := c, -1.0
		for i := max(0, c-win); i <= min(L-1, c+win); i++ {
			if prof[i] > bv {
				bi, bv = i, prof[i]
			}
		}
		lines[k] = float64(bi * step)
	}
	return lines, true
}

// ExtractCellQuad warps the cell (col,row) of a detected grid into a
// w×h image with bilinear sampling of the quad corners.
func (g DetectedGrid) ExtractCellQuad(img image.Image, col, row, w, h int) *image.NRGBA {
	b := img.Bounds()
	iw, ih := float64(b.Dx()), float64(b.Dy())
	x00, y00 := g.corner(col, row, iw, ih)
	x10, y10 := g.corner(col+1, row, iw, ih)
	x01, y01 := g.corner(col, row+1, iw, ih)
	x11, y11 := g.corner(col+1, row+1, iw, ih)
	out := image.NewNRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		v := (float64(y) + 0.5) / float64(h)
		for x := 0; x < w; x++ {
			u := (float64(x) + 0.5) / float64(w)
			sx := (1-u)*(1-v)*x00 + u*(1-v)*x10 + (1-u)*v*x01 + u*v*x11
			sy := (1-u)*(1-v)*y00 + u*(1-v)*y10 + (1-u)*v*y01 + u*v*y11
			out.SetNRGBA(x, y, bilinear(img, sx+float64(b.Min.X), sy+float64(b.Min.Y)))
		}
	}
	return out
}

func bilinear(img image.Image, x, y float64) color.NRGBA {
	b := img.Bounds()
	x0, y0 := int(math.Floor(x-0.5)), int(math.Floor(y-0.5))
	fx, fy := x-0.5-float64(x0), y-0.5-float64(y0)
	var acc [4]float64
	for dy := 0; dy <= 1; dy++ {
		for dx := 0; dx <= 1; dx++ {
			px := min(max(x0+dx, b.Min.X), b.Max.X-1)
			py := min(max(y0+dy, b.Min.Y), b.Max.Y-1)
			c := color.NRGBAModel.Convert(img.At(px, py)).(color.NRGBA)
			wgt := (1 - math.Abs(float64(dx)-fx)) * (1 - math.Abs(float64(dy)-fy))
			acc[0] += float64(c.R) * wgt
			acc[1] += float64(c.G) * wgt
			acc[2] += float64(c.B) * wgt
			acc[3] += float64(c.A) * wgt
		}
	}
	return color.NRGBA{uint8(acc[0] + 0.5), uint8(acc[1] + 0.5), uint8(acc[2] + 0.5), uint8(acc[3] + 0.5)}
}

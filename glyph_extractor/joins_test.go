package main

import (
	"image"
	"image/color"
	"math"
	"testing"
)

// penImage draws round-pen strokes through the given polylines.
func penImage(w, h int, width float64, lines ...[][2]float64) *image.NRGBA {
	img := image.NewNRGBA(image.Rect(0, 0, w, h))
	for _, pts := range lines {
		for i := 0; i+1 < len(pts); i++ {
			a, b := pts[i], pts[i+1]
			n := int(math.Hypot(b[0]-a[0], b[1]-a[1])*2) + 1
			for s := 0; s <= n; s++ {
				t := float64(s) / float64(n)
				cx, cy := a[0]+(b[0]-a[0])*t, a[1]+(b[1]-a[1])*t
				for y := int(cy - width); y <= int(cy+width); y++ {
					for x := int(cx - width); x <= int(cx+width); x++ {
						if x >= 0 && y >= 0 && x < w && y < h && math.Hypot(float64(x)-cx, float64(y)-cy) <= width/2 {
							img.SetNRGBA(x, y, color.NRGBA{0, 0, 0, 255})
						}
					}
				}
			}
		}
	}
	return img
}

func ring(w, h int, cx, cy, r, width float64) *image.NRGBA {
	var pts [][2]float64
	for a := 0; a <= 360; a += 5 {
		rad := float64(a) * math.Pi / 180
		pts = append(pts, [2]float64{cx + r*math.Cos(rad), cy + r*math.Sin(rad)})
	}
	return penImage(w, h, width, pts)
}

func TestStrokeEndsOfABar(t *testing.T) {
	bd := glyphBody(penImage(120, 40, 7, [][2]float64{{10, 20}, {110, 20}}))
	ends := strokeEnds(thin(bd.mask, bd.w, bd.h), bd.w, bd.h, 15)
	if len(ends) != 2 {
		t.Fatalf("got %d stroke ends, want 2", len(ends))
	}
	left, right := ends[0], ends[1]
	if left.x > right.x {
		left, right = right, left
	}
	if left.x > 20 || right.x < 100 {
		t.Errorf("ends at x=%d and x=%d, want near 10 and 110", left.x, right.x)
	}
	if left.dx > -0.9 || right.dx < 0.9 {
		t.Errorf("directions %.2f and %.2f should point out of the bar", left.dx, right.dx)
	}
}

func TestEstimateSlant(t *testing.T) {
	for _, want := range []float64{0, 20, -12} {
		k := math.Tan(want * math.Pi / 180)
		// A stem from the baseline (y=180) up 150 px, leaning by want degrees.
		bd := glyphBody(penImage(260, 200, 7, [][2]float64{{130, 180}, {130 + 150*k, 30}}))
		if got := estimateSlant(bd, 180); math.Abs(got-want) > 1.5 {
			t.Errorf("slant = %.1f°, want %.1f°", got, want)
		}
	}
}

func TestShearGlyphKeepsBaselinePoint(t *testing.T) {
	k := math.Tan(25 * math.Pi / 180)
	g := SheetGlyph{
		Key:     "l",
		Image:   penImage(260, 200, 7, [][2]float64{{130, 180}, {130 + 150*k, 30}}),
		Metrics: GlyphMetrics{Width: 260, Height: 200, Baseline: 180},
	}
	out := shearGlyph(g, -10, 2)
	if got := estimateSlant(glyphBody(out.Image), out.Metrics.Baseline); math.Abs(got-15) > 2 {
		t.Errorf("slant after shearing 25° by -10° = %.1f°, want 15°", got)
	}
	if out.Metrics.Width != out.Image.Bounds().Dx() || out.Metrics.Height != out.Image.Bounds().Dy() {
		t.Errorf("metrics %dx%d do not match image %v", out.Metrics.Width, out.Metrics.Height, out.Image.Bounds())
	}
}

func TestJoinPointsFromStrokeEnds(t *testing.T) {
	// Baseline y=120, x-height 80: a stroke coming in from the left at
	// mid height, down a stem and out to the right along the baseline.
	img := penImage(140, 140, 7, [][2]float64{{10, 80}, {60, 80}, {60, 116}, {130, 116}})
	bd := glyphBody(img)
	sk := thin(bd.mask, bd.w, bd.h)
	entry, exit := joinPoints(bd, sk, 120, 80, 7, true)
	if entry == nil || exit == nil {
		t.Fatalf("entry %v, exit %v: both expected", entry, exit)
	}
	if entry[0] > 20 || abs(entry[1]-80) > 4 || abs(entry[2]) > 10 {
		t.Errorf("entry = %v, want about [10 80 0]", *entry)
	}
	if exit[0] < 120 || abs(exit[1]-116) > 4 || abs(exit[2]) > 10 {
		t.Errorf("exit = %v, want about [130 116 0]", *exit)
	}

	// A capital only joins forwards.
	entry, exit = joinPoints(bd, sk, 120, 80, 7, false)
	if entry != nil || exit == nil {
		t.Errorf("capital: entry %v (want none), exit %v (want one)", entry, exit)
	}

	// Ends above the band (an ascender's tip) are not join points.
	if _, exit = joinPoints(bd, sk, 320, 80, 7, false); exit != nil {
		t.Errorf("stroke end far above the x-height became exit %v", *exit)
	}
}

func TestJoinPointsOfAClosedLetter(t *testing.T) {
	// An "o": no loose ends. Lowercase joins at the outline, capitals do not.
	img := ring(120, 140, 60, 80, 36, 7)
	bd := glyphBody(img)
	sk := thin(bd.mask, bd.w, bd.h)
	entry, exit := joinPoints(bd, sk, 120, 80, 7, true)
	if entry == nil || exit == nil {
		t.Fatalf("entry %v, exit %v: both expected", entry, exit)
	}
	if entry[0] > 30 || exit[0] < 90 {
		t.Errorf("entry x=%d, exit x=%d should sit on the left and right of the ring", entry[0], exit[0])
	}
	if entry, exit = joinPoints(bd, sk, 120, 80, 7, false); entry != nil || exit != nil {
		t.Errorf("capital without stroke ends got entry %v, exit %v", entry, exit)
	}
}

func TestPrepareJoinsEvensXHeightAndBaseline(t *testing.T) {
	sb := NewSheetBuilder("t", "T", "handwriting", 300)
	add := func(key string, h, baselineOff int) {
		// A ring h px tall whose bottom sits baselineOff px above the
		// recorded baseline (y=150).
		r := float64(h)/2 - 3.5
		img := ring(160, 170, 80, 150-float64(baselineOff)-float64(h)/2, r, 7)
		sb.Add(SheetGlyph{Key: key, Image: img, Metrics: GlyphMetrics{Width: 160, Height: 170, Baseline: 150}, Row: -1})
	}
	add("a", 100, 0)
	add("c", 100, 0)
	add("e", 100, 8) // written a little above the line
	add("o", 120, 0) // written too big
	add("n", 101, 0)
	log := sb.PrepareJoins(JoinOptions{Joins: true, FixXHeight: true, SnapBaseline: true}, 2)
	if len(log) == 0 {
		t.Fatal("no log lines")
	}
	if math.Abs(sb.xHeight-100) > 3 {
		t.Errorf("x-height = %.1f, want about 100", sb.xHeight)
	}
	if math.Abs(sb.strokeWidth-7) > 2 {
		t.Errorf("stroke width = %.1f, want about 7", sb.strokeWidth)
	}
	for _, g := range sb.glyphs {
		bd := glyphBody(g.Image)
		h := g.Metrics.Baseline - bd.bounds.Min.Y
		switch g.Key {
		case "e":
			if h < 97 || h > 103 {
				t.Errorf("e: body height above the baseline = %d, want about 100 (baseline snapped)", h)
			}
		case "o":
			if h > 106 {
				t.Errorf("o: body height = %d, want scaled down towards 100", h)
			}
		}
		if g.Metrics.Entry == nil || g.Metrics.Exit == nil {
			t.Errorf("%s: missing join points", g.Key)
		}
	}

	// Size normalisation carries the points and sheet measures along.
	before := *sb.glyphs[0].Metrics.Exit
	sb.Scale(0.5)
	after := *sb.glyphs[0].Metrics.Exit
	if abs(after[0]*2-before[0]) > 2 || abs(after[1]*2-before[1]) > 2 || after[2] != before[2] {
		t.Errorf("exit %v scaled by 0.5 = %v", before, after)
	}
	if math.Abs(sb.xHeight-50) > 2 {
		t.Errorf("x-height after scaling = %.1f, want about 50", sb.xHeight)
	}
}

func TestJoinsOnlyForHandwriting(t *testing.T) {
	on := JoinOptions{Joins: true, FixSlant: true, FixXHeight: true, SnapBaseline: true}
	if !joinOptions(on, SheetMeta{Source: "handwriting"}).any() {
		t.Error("handwriting sheets should get joins")
	}
	if joinOptions(on, SheetMeta{Source: "material"}).any() || joinOptions(on, SheetMeta{Source: "handwriting", Colored: true}).any() {
		t.Error("material and coloured sheets must not get joins")
	}
}

func TestJoinGapAndCurve(t *testing.T) {
	if g := JoinGap(100, 0); math.Abs(g-10) > 1e-9 {
		t.Errorf("JoinGap(100, 0) = %v, want 10", g)
	}
	if JoinGap(100, -20) != JoinGap(100, 20) || JoinGap(100, 20) <= JoinGap(100, 0) {
		t.Error("the gap must grow with the height difference, up or down")
	}
	// A direction pointing backwards may not make the curve loop back.
	p := joinCurve(0, 0, 170, 30, 0, 0)
	if p[1][0] <= 0 {
		t.Errorf("control point %v left of the start", p[1])
	}
}

func abs(v int) int {
	if v < 0 {
		return -v
	}
	return v
}

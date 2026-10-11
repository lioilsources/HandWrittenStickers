package main

import (
	"encoding/json"
	"image"
	"image/color"
	"image/draw"
	"math"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
)

func TestOneOrManyRoundTrip(t *testing.T) {
	m := NewManifest("t", "T", "handwriting", 300)
	m.Add("a", "a.png", GlyphMetrics{Width: 1})
	m.Add("a", "a_1.png", GlyphMetrics{Width: 2})
	m.Add("b", "b.png", GlyphMetrics{Width: 3})
	dir := t.TempDir()
	if err := m.Write(dir); err != nil {
		t.Fatal(err)
	}
	raw, _ := os.ReadFile(filepath.Join(dir, "glyphs.json"))
	var generic map[string]any
	if err := json.Unmarshal(raw, &generic); err != nil {
		t.Fatal(err)
	}
	if v := generic["version"].(float64); v != 3 {
		t.Errorf("version = %v, want 3 (variants present)", v)
	}
	glyphs := generic["glyphs"].(map[string]any)
	if _, ok := glyphs["b"].(string); !ok {
		t.Errorf("single variant should be written as a string, got %T", glyphs["b"])
	}
	if l, ok := glyphs["a"].([]any); !ok || len(l) != 2 {
		t.Errorf("variants should be a list of 2, got %v", glyphs["a"])
	}
	back, err := ReadManifest(dir)
	if err != nil {
		t.Fatal(err)
	}
	if len(back.Glyphs["a"]) != 2 || back.Metrics["a"][1].Width != 2 || len(back.Glyphs["b"]) != 1 {
		t.Errorf("round trip lost data: %+v", back.Glyphs)
	}
}

func fill(img draw.Image, r image.Rectangle, c color.Color) {
	draw.Draw(img, r, image.NewUniform(c), image.Point{}, draw.Src)
}

func TestChromaKeyingKeepsColouredInk(t *testing.T) {
	beige := color.NRGBA{235, 220, 190, 255}
	red := color.NRGBA{200, 40, 30, 255}
	img := image.NewNRGBA(image.Rect(0, 0, 100, 100))
	fill(img, img.Bounds(), beige)
	fill(img, image.Rect(40, 20, 60, 80), red)

	bg := SampleBackground(img)
	if bg != beige {
		t.Fatalf("sampled background %v, want %v", bg, beige)
	}
	out := MakeTransparentChroma(img, bg, 12)
	if a := out.NRGBAAt(5, 5).A; a != 0 {
		t.Errorf("background alpha = %d, want 0", a)
	}
	if c := out.NRGBAAt(50, 50); c.A != 255 || c.R != red.R {
		t.Errorf("ink = %v, want opaque red", c)
	}
	// Lightness keying would drop light-coloured ink; chroma keeps it.
	yellow := color.NRGBA{250, 220, 60, 255}
	fill(img, image.Rect(10, 10, 20, 20), yellow)
	if a := MakeTransparentChroma(img, bg, 12).NRGBAAt(15, 15).A; a != 255 {
		t.Errorf("light yellow ink alpha = %d, want 255", a)
	}
	if a := MakeTransparent(img, 160).(*image.NRGBA).NRGBAAt(15, 15).A; a != 0 {
		t.Errorf("sanity: lightness keying should drop yellow, alpha %d", a)
	}
}

func TestProcessCellIgnoresSpecksAndGridLines(t *testing.T) {
	cell := image.NewNRGBA(image.Rect(0, 0, 265, 309))
	fill(cell, cell.Bounds(), color.White)
	black := color.Black
	fill(cell, image.Rect(100, 90, 160, 232), black) // the letter, bottom at 232 ≈ baseline
	fill(cell, image.Rect(0, 0, 265, 2), black)      // grid line along the top edge
	fill(cell, image.Rect(263, 0, 265, 309), black)  // grid line along the right edge
	fill(cell, image.Rect(20, 280, 22, 282), black)  // speck

	glyph, rect, ok := ProcessCell(cell, DefaultCellOptions())
	if !ok {
		t.Fatal("cell reported empty")
	}
	want := image.Rect(98, 88, 162, 234)
	if rect != want {
		t.Errorf("crop = %v, want %v (letter + 2 px padding)", rect, want)
	}
	if glyph.Bounds().Dx() != want.Dx() || glyph.Bounds().Dy() != want.Dy() {
		t.Errorf("glyph size %v", glyph.Bounds())
	}
	m := CellMetrics(rect, 232)
	if m.Baseline != 232-88 {
		t.Errorf("baseline = %d, want %d", m.Baseline, 232-88)
	}

	empty := image.NewNRGBA(image.Rect(0, 0, 265, 309))
	fill(empty, empty.Bounds(), color.White)
	fill(empty, image.Rect(0, 0, 265, 2), black)
	if _, _, ok := ProcessCell(empty, DefaultCellOptions()); ok {
		t.Error("cell with only a grid line should be empty")
	}
}

func loadTestFace(t *testing.T, px float64) font.Face {
	t.Helper()
	data, err := os.ReadFile("fonts/DejaVuSans.ttf")
	if err != nil {
		t.Skip("fonts/DejaVuSans.ttf not available")
	}
	f, err := opentype.Parse(data)
	if err != nil {
		t.Fatal(err)
	}
	face, err := opentype.NewFace(f, &opentype.FaceOptions{Size: px, DPI: 72, Hinting: font.HintingNone})
	if err != nil {
		t.Fatal(err)
	}
	return face
}

// writePage renders lines of text in black on white, one per line.
func writePage(t *testing.T, lines []string) string {
	face := loadTestFace(t, 60)
	defer face.Close()
	page := image.NewNRGBA(image.Rect(0, 0, 1800, 150*len(lines)+100))
	fill(page, page.Bounds(), color.White)
	d := &font.Drawer{Dst: page, Src: image.Black, Face: face}
	for i, l := range lines {
		// Letter spacing so glyphs never touch (like printed handwriting).
		x := 40
		for _, r := range l {
			d.Dot = fixed.P(x, 120+150*i)
			d.DrawString(string(r))
			x += d.MeasureString(string(r)).Round() + 14
		}
	}
	path := filepath.Join(t.TempDir(), "page.png")
	if err := savePNG(page, path); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestSegmentAndAssemble(t *testing.T) {
	lines := []string{"Příliš žluťoučký kůň", "úpěl ďábelské ódy!", "HIJ: ahoj"}
	page := writePage(t, lines)
	out := t.TempDir()
	if err := segmentPage(SegmentOptions{Input: page, OutputDir: out, DPI: 300, Padding: 2, Labels: lines}); err != nil {
		t.Fatal(err)
	}
	raw, err := os.ReadFile(filepath.Join(out, "candidates.json"))
	if err != nil {
		t.Fatal(err)
	}
	var cf CandidatesFile
	if err := json.Unmarshal(raw, &cf); err != nil {
		t.Fatal(err)
	}
	want := 0
	for _, l := range lines {
		want += len([]rune(strings.ReplaceAll(l, " ", "")))
	}
	if len(cf.Candidates) != want {
		t.Fatalf("got %d candidates, want %d (diacritics, dots and colon must merge)", len(cf.Candidates), want)
	}
	var got strings.Builder
	for _, c := range cf.Candidates {
		if c.Label == "" {
			t.Fatalf("candidate %d unlabelled (line %d)", c.ID, c.Line)
		}
		got.WriteString(c.Label)
	}
	if exp := strings.ReplaceAll(strings.Join(lines, ""), " ", ""); got.String() != exp {
		t.Errorf("labels %q, want %q", got.String(), exp)
	}

	sheet := t.TempDir()
	meta := SheetMeta{ID: "seg", Name: "Seg", Source: "handwriting", CapRatio: 0.7}
	if err := assembleSheet(filepath.Join(out, "candidates.json"), "", sheet, "", meta, 5, 2, 0); err != nil {
		t.Fatal(err)
	}
	m, err := ReadManifest(sheet)
	if err != nil {
		t.Fatal(err)
	}
	if n := len(m.Glyphs["l"]); n != 4 {
		t.Errorf("'l' has %d variants, want 4", n)
	}
	if m.Version != 3 {
		t.Errorf("version %d, want 3", m.Version)
	}
	// Baselines: 'p' descends, 'H' sits on the line.
	h, p := m.Metrics["H"][0], m.Metrics["p"][0]
	if h.Baseline < h.Height-4 {
		t.Errorf("H baseline %d should be at its bottom (h=%d)", h.Baseline, h.Height)
	}
	if p.Baseline > p.Height*85/100 {
		t.Errorf("p baseline %d should be well above its bottom (h=%d)", p.Baseline, p.Height)
	}
	// Cap height normalised to 0.70 em (the 2 px padding is scaled too).
	cap := 0.7 * float64(m.EmHeight)
	if hh := float64(h.Height); hh < cap || hh > cap*1.12 {
		t.Errorf("H height %.0f, want ink %.0f + scaled padding", hh, cap)
	}
}

func TestAssembleComposesAccents(t *testing.T) {
	dir := t.TempDir()
	os.MkdirAll(filepath.Join(dir, "candidates"), 0755)
	mk := func(name string, w, h int, rects ...image.Rectangle) {
		img := image.NewNRGBA(image.Rect(0, 0, w, h))
		for _, r := range rects {
			fill(img, r, color.Black)
		}
		if err := savePNG(img, filepath.Join(dir, "candidates", name)); err != nil {
			t.Fatal(err)
		}
	}
	mk("c.png", 44, 44, image.Rect(2, 2, 42, 42))
	mk("i.png", 14, 64, image.Rect(2, 22, 12, 62), image.Rect(2, 2, 12, 12)) // stem + dot
	mk("caron.png", 24, 14, image.Rect(2, 2, 22, 12))
	mk("acute.png", 14, 14, image.Rect(2, 2, 12, 12))
	cf := CandidatesFile{Version: 1, DPI: 300, Candidates: []Candidate{
		{ID: 0, File: "candidates/c.png", BBox: [4]int{0, 0, 44, 44}, Label: "c"},
		{ID: 1, File: "candidates/i.png", BBox: [4]int{0, 0, 14, 64}, Label: "i"},
		{ID: 2, File: "candidates/caron.png", BBox: [4]int{0, 0, 24, 14}, Label: "caron"},
		{ID: 3, File: "candidates/acute.png", BBox: [4]int{0, 0, 14, 14}, Label: "acute"},
	}}
	raw, _ := json.Marshal(cf)
	os.WriteFile(filepath.Join(dir, "candidates.json"), raw, 0644)
	// labels.json skips the acute → no í; then relabel to keep it.
	skip := "c"
	lf := LabelsFile{Version: 1, Labels: map[string]*string{"0": &skip}}
	raw, _ = json.Marshal(lf)
	os.WriteFile(filepath.Join(dir, "labels.json"), raw, 0644)

	sheet := t.TempDir()
	meta := SheetMeta{ID: "cmp", Source: "dataset", CapRatio: 0}
	if err := assembleSheet(filepath.Join(dir, "candidates.json"), filepath.Join(dir, "labels.json"), sheet, "", meta, 5, 2, 0); err != nil {
		t.Fatal(err)
	}
	m, _ := ReadManifest(sheet)
	if got := m.Compose["č"]; len(got) != 2 || got[0] != "c" || got[1] != "caron" {
		t.Errorf("compose č = %v", got)
	}
	if got := m.Compose["í"]; len(got) != 2 || got[0] != "ı" {
		t.Errorf("compose í = %v, want dotless ı base", got)
	}
	if len(m.Glyphs["ı"]) != 1 || m.Glyphs["ı"][0] != "dotlessi.png" {
		t.Errorf("dotless i not written: %v", m.Glyphs["ı"])
	}
	img, err := loadImage(filepath.Join(sheet, "dotlessi.png"))
	if err != nil {
		t.Fatal(err)
	}
	if _, _, _, a := img.At(6, 6).RGBA(); a != 0 {
		t.Error("dot of i should be removed in the dotless variant")
	}
}

func TestDetectGridOnGuidePage(t *testing.T) {
	cfg := GridConfig{CellWidthMM: 22.5, CellHeightMM: 26.2, Columns: 8, Rows: 10, DPI: 150, MarginTopMM: 15, MarginLeftMM: 15}
	w, h := cfg.mmToPixels(210), cfg.mmToPixels(297)
	page := image.NewNRGBA(image.Rect(0, 0, w, h))
	fill(page, page.Bounds(), color.NRGBA{230, 228, 222, 255})
	grey := color.NRGBA{150, 150, 150, 255}
	for c := 0; c <= 8; c++ {
		x := cfg.MarginLeftPx() + c*cfg.CellWidthPx()
		fill(page, image.Rect(x, cfg.MarginTopPx(), x+2, cfg.MarginTopPx()+10*cfg.CellHeightPx()), grey)
	}
	for r := 0; r <= 10; r++ {
		y := cfg.MarginTopPx() + r*cfg.CellHeightPx()
		fill(page, image.Rect(cfg.MarginLeftPx(), y, cfg.MarginLeftPx()+8*cfg.CellWidthPx(), y+2), grey)
	}
	// Some "handwriting" blobs that must not confuse the detector.
	for i := 0; i < 30; i++ {
		x, y := 60+i*37%700, 80+i*97%1400
		fill(page, image.Rect(x, y, x+18, y+30), color.NRGBA{90, 40, 120, 255})
	}
	g, ok := DetectGrid(page, 8, 10)
	if !ok {
		t.Fatal("grid not found")
	}
	for c := 0; c <= 8; c++ {
		want := float64(cfg.MarginLeftPx() + c*cfg.CellWidthPx())
		if math.Abs(g.XTop[c]-want) > 3 || math.Abs(g.XBottom[c]-want) > 3 {
			t.Errorf("vertical line %d at %.0f/%.0f, want %.0f", c, g.XTop[c], g.XBottom[c], want)
		}
	}
	for r := 0; r <= 10; r++ {
		want := float64(cfg.MarginTopPx() + r*cfg.CellHeightPx())
		if math.Abs(g.YLeft[r]-want) > 3 {
			t.Errorf("horizontal line %d at %.0f, want %.0f", r, g.YLeft[r], want)
		}
	}
}

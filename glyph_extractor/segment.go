package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"image"
	"image/color"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"unicode"

	"golang.org/x/text/unicode/norm"
)

// CandidatesFile is candidates.json: glyph candidates cut out of free-form
// writing (segment) or a dataset (tools/sheets/nist.py), to be labelled
// (tools/sheets/label.html) and turned into a sheet (assemble).
type CandidatesFile struct {
	Version    int         `json:"version"`
	Source     string      `json:"source"`
	DPI        int         `json:"dpi"`
	Candidates []Candidate `json:"candidates"`
}

// Candidate is one cut-out glyph. File is relative to candidates.json.
type Candidate struct {
	ID    int    `json:"id"`
	File  string `json:"file"`
	Line  int    `json:"line"`
	Order int    `json:"order"`
	// BBox is [x0, y0, x1, y1] of the PNG in source-image pixels.
	BBox [4]int `json:"bbox"`
	// Baseline is the line baseline y in source-image pixels, if known.
	Baseline *int   `json:"baseline,omitempty"`
	Label    string `json:"label,omitempty"`
}

// SegmentOptions configures segmentation of a page of free-form writing.
type SegmentOptions struct {
	Input     string
	OutputDir string
	DPI       int
	Threshold int // 0 = Otsu
	Padding   int
	Labels    []string // transcript, one string per written line
}

func runSegment(args []string) error {
	fs := flag.NewFlagSet("segment", flag.ContinueOnError)
	opts := SegmentOptions{}
	var labels, labelsFile, ocr, ocrLang string
	fs.StringVar(&opts.Input, "input", "", "Page image (PNG/JPEG), ideally straightened with the Grid Alignment tool")
	fs.StringVar(&opts.OutputDir, "output", "./segment", "Output directory for candidates/ and candidates.json")
	fs.IntVar(&opts.DPI, "dpi", 300, "Image DPI (scales noise filters)")
	fs.IntVar(&opts.Threshold, "threshold", 0, "Ink threshold 0-255 (0 = automatic, Otsu)")
	fs.IntVar(&opts.Padding, "padding", 2, "Transparent padding in px around each candidate")
	fs.StringVar(&labels, "labels", "", `Transcript of the page, lines separated by "\n"; characters are paired in reading order`)
	fs.StringVar(&labelsFile, "labels-file", "", "Transcript file (one written line per line), e.g. the .txt written by template -pangram")
	fs.StringVar(&ocr, "ocr", "", "Pre-label with an OCR engine: tesseract")
	fs.StringVar(&ocrLang, "ocr-lang", "ces", "OCR language")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if opts.Input == "" {
		fs.Usage()
		return fmt.Errorf("-input is required")
	}
	switch {
	case labelsFile != "":
		data, err := os.ReadFile(labelsFile)
		if err != nil {
			return err
		}
		labels = string(data)
	case labels != "":
		labels = strings.ReplaceAll(labels, `\n`, "\n")
	case ocr == "tesseract":
		out, err := exec.Command("tesseract", opts.Input, "-", "-l", ocrLang, "--psm", "6").Output()
		if err != nil {
			return fmt.Errorf("tesseract failed (installed? `brew install tesseract tesseract-lang`): %w", err)
		}
		labels = string(out)
		fmt.Printf("OCR transcript:\n%s\n", labels)
	case ocr != "":
		return fmt.Errorf("unknown -ocr engine %q", ocr)
	}
	for _, l := range strings.Split(labels, "\n") {
		if strings.TrimSpace(l) != "" {
			opts.Labels = append(opts.Labels, l)
		}
	}
	return segmentPage(opts)
}

// glyphGroup is one candidate glyph: one or more ink components (a letter
// plus its diacritics or dots).
type glyphGroup struct {
	comps  []int
	bounds image.Rectangle
	main   image.Rectangle // bounds of the largest component
}

func segmentPage(opts SegmentOptions) error {
	img, err := loadImage(opts.Input)
	if err != nil {
		return err
	}
	gray := toGray(img)
	thr := opts.Threshold
	if thr <= 0 {
		thr = otsu(gray)
	}
	b := gray.Bounds()
	w, h := b.Dx(), b.Dy()
	fmt.Printf("%s: %dx%d px, ink threshold %d\n", opts.Input, w, h, thr)

	// Ink mask as alpha so connectedComponents can be reused.
	mask := image.NewNRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			if int(gray.Pix[y*gray.Stride+x]) < thr {
				mask.Pix[y*mask.Stride+x*4+3] = 255
			}
		}
	}
	labels, comps := connectedComponents(mask, 255)

	// Drop noise and ruled lines.
	minArea := max(6, opts.DPI*opts.DPI/5000)
	var valid []int
	for i, c := range comps {
		cb := c.bounds
		if c.area < minArea {
			continue
		}
		if cb.Dx() > w/3 && cb.Dy() < h/100 { // printed rule
			continue
		}
		valid = append(valid, i)
	}
	if len(valid) == 0 {
		return fmt.Errorf("no ink found")
	}

	groups := groupDiacritics(comps, valid)
	lines := splitLines(groups)
	fmt.Printf("Found %d glyph candidates in %d lines\n", len(groups), len(lines))

	candDir := filepath.Join(opts.OutputDir, "candidates")
	if err := os.MkdirAll(candDir, 0755); err != nil {
		return err
	}
	out := CandidatesFile{Version: 1, Source: filepath.Base(opts.Input), DPI: opts.DPI}
	keyThr := uint8(min(255, thr+thr/8))

	for li, line := range lines {
		baseline := lineBaseline(line)
		var transcript []rune
		if li < len(opts.Labels) {
			for _, r := range norm.NFC.String(opts.Labels[li]) {
				if !unicode.IsSpace(r) {
					transcript = append(transcript, r)
				}
			}
			if len(transcript) != len(line) {
				fmt.Printf("  line %d: %d candidates but transcript has %d characters – left unlabelled (fix in label.html)\n",
					li+1, len(line), len(transcript))
				transcript = nil
			}
		}
		for oi, g := range line {
			id := len(out.Candidates)
			crop := image.Rect(g.bounds.Min.X-opts.Padding, g.bounds.Min.Y-opts.Padding,
				g.bounds.Max.X+opts.Padding, g.bounds.Max.Y+opts.Padding).Intersect(image.Rect(0, 0, w, h))
			glyph := cutGroup(img, labels, w, g, crop, keyThr)
			file := fmt.Sprintf("candidates/%04d.png", id)
			if err := savePNG(glyph, filepath.Join(opts.OutputDir, file)); err != nil {
				return err
			}
			bl := baseline
			c := Candidate{
				ID: id, File: file, Line: li, Order: oi,
				BBox:     [4]int{crop.Min.X, crop.Min.Y, crop.Max.X, crop.Max.Y},
				Baseline: &bl,
			}
			if transcript != nil {
				c.Label = string(transcript[oi])
			}
			out.Candidates = append(out.Candidates, c)
		}
	}
	if len(opts.Labels) > 0 && len(opts.Labels) != len(lines) {
		fmt.Printf("  warning: transcript has %d lines, page has %d\n", len(opts.Labels), len(lines))
	}

	data, err := json.MarshalIndent(out, "", "  ")
	if err != nil {
		return err
	}
	path := filepath.Join(opts.OutputDir, "candidates.json")
	if err := os.WriteFile(path, data, 0644); err != nil {
		return err
	}
	labelled := 0
	for _, c := range out.Candidates {
		if c.Label != "" {
			labelled++
		}
	}
	fmt.Printf("Wrote %s (%d candidates, %d labelled)\n", path, len(out.Candidates), labelled)
	return nil
}

// groupDiacritics merges small components with the glyph they belong to:
// accents, i/j dots and rings above a letter, and the separate dots of
// ! ? : ; (plan A3: a small component within 0.6 × the letter height).
func groupDiacritics(comps []component, valid []int) []glyphGroup {
	parent := make(map[int]int, len(valid))
	for _, i := range valid {
		parent[i] = i
	}
	var find func(int) int
	find = func(i int) int {
		for parent[i] != i {
			parent[i] = parent[parent[i]]
			i = parent[i]
		}
		return i
	}

	// Sort by area so small components look for a larger partner.
	// Reference glyph height: 75th percentile of component heights (dots and
	// accents are the small minority).
	hs := make([]int, len(valid))
	for i, v := range valid {
		hs[i] = comps[v].bounds.Dy()
	}
	sort.Ints(hs)
	refH := hs[len(hs)*3/4]

	byArea := append([]int(nil), valid...)
	sort.Slice(byArea, func(a, b int) bool { return comps[byArea[a]].area < comps[byArea[b]].area })

	for _, si := range byArea {
		s := comps[si].bounds
		best, bestGap := -1, 1<<30
		for _, bi := range valid {
			if bi == si {
				continue
			}
			bb := comps[bi].bounds
			// Only attach the smaller component to the larger one.
			if comps[si].area > comps[bi].area {
				continue
			}
			dot := func(r image.Rectangle) bool { return r.Dy() <= r.Dx()*2 && r.Dx() <= r.Dy()*2 }
			bothDots := dot(s) && dot(bb) && s.Dy() < refH/2 && bb.Dy() < refH/2
			// Caron of ď / ť: a small mark right of the ascender's top.
			side := comps[si].area*3 < comps[bi].area &&
				s.Min.X >= bb.Max.X-bb.Dx()/3 && s.Min.X-bb.Max.X <= max(s.Dx(), bb.Dx()/4) &&
				s.Min.Y >= bb.Min.Y-s.Dy()/2 && s.Max.Y <= bb.Min.Y+bb.Dy()*2/5
			// The mark sits over (or under) the partner: its centre lies within
			// the partner's width, with a little slack for slanted writing.
			cx := (s.Min.X + s.Max.X) / 2
			slack := s.Dx()/2 + bb.Dx()/10
			if !side && (cx < bb.Min.X-slack || cx > bb.Max.X+slack) {
				continue
			}
			above := s.Max.Y <= bb.Min.Y+s.Dy()/2
			below := s.Min.Y >= bb.Max.Y-s.Dy()/2
			if !above && !below && !side {
				continue
			}
			// Vertical gap between the boxes (0 when they touch). The dots of
			// a colon are further apart than their own size.
			gap := max(0, max(bb.Min.Y-s.Max.Y, s.Min.Y-bb.Max.Y))
			tol := max(bb.Dy(), s.Dy()) * 6 / 10
			if bothDots {
				tol = refH * 8 / 10
			}
			if gap > tol {
				continue
			}
			// Marks are small: clearly shorter than the letter, or both are
			// dots of similar size (colon).
			if s.Dy() >= bb.Dy()*6/10 && !bothDots {
				continue
			}
			if gap < bestGap {
				best, bestGap = bi, gap
			}
		}
		if best >= 0 {
			parent[find(si)] = find(best)
		}
	}

	byRoot := map[int]*glyphGroup{}
	var order []int
	for _, i := range valid {
		r := find(i)
		g, ok := byRoot[r]
		if !ok {
			g = &glyphGroup{}
			byRoot[r] = g
			order = append(order, r)
		}
		g.comps = append(g.comps, i)
		g.bounds = g.bounds.Union(comps[i].bounds)
		if g.main.Empty() || comps[i].area > area(g.main) {
			g.main = comps[i].bounds
		}
	}
	groups := make([]glyphGroup, 0, len(order))
	for _, r := range order {
		groups = append(groups, *byRoot[r])
	}
	return groups
}

func area(r image.Rectangle) int { return r.Dx() * r.Dy() }

// splitLines clusters glyph groups into text lines (top to bottom) and sorts
// each line left to right. Lines are separated where the vertical centre of
// a glyph's main component is further than 0.6 × the median glyph height
// from the running centre of the current line.
func splitLines(groups []glyphGroup) [][]glyphGroup {
	if len(groups) == 0 {
		return nil
	}
	hs := make([]int, len(groups))
	for i, g := range groups {
		hs[i] = g.main.Dy()
	}
	medH := median(hs)
	sort.Slice(groups, func(a, b int) bool { return centerY(groups[a]) < centerY(groups[b]) })

	var lines [][]glyphGroup
	var cur []glyphGroup
	var sum float64
	for _, g := range groups {
		cy := float64(centerY(g))
		if len(cur) > 0 && cy-sum/float64(len(cur)) > float64(medH)*0.6 {
			lines = append(lines, cur)
			cur, sum = nil, 0
		}
		cur = append(cur, g)
		sum += cy
	}
	lines = append(lines, cur)
	for _, l := range lines {
		sort.Slice(l, func(a, b int) bool { return l[a].bounds.Min.X < l[b].bounds.Min.X })
	}
	return lines
}

func centerY(g glyphGroup) int { return (g.main.Min.Y + g.main.Max.Y) / 2 }

// lineBaseline estimates the baseline as the median bottom of the main
// components (descenders are a minority in any language).
func lineBaseline(line []glyphGroup) int {
	bottoms := make([]int, len(line))
	for i, g := range line {
		bottoms[i] = g.main.Max.Y
	}
	return median(bottoms)
}

// cutGroup crops the group from the page, keeps only pixels near the group's
// own components (neighbouring letters overlapping the box are removed) and
// keys the paper to transparent.
func cutGroup(img image.Image, labels []int32, w int, g glyphGroup, crop image.Rectangle, thr uint8) *image.NRGBA {
	own := map[int32]bool{}
	for _, c := range g.comps {
		own[int32(c+1)] = true
	}
	const fringe = 2
	out := image.NewNRGBA(image.Rect(0, 0, crop.Dx(), crop.Dy()))
	b := img.Bounds()
	h := len(labels) / w
	for y := crop.Min.Y; y < crop.Max.Y; y++ {
		for x := crop.Min.X; x < crop.Max.X; x++ {
			near := false
			for dy := -fringe; dy <= fringe && !near; dy++ {
				for dx := -fringe; dx <= fringe; dx++ {
					nx, ny := x+dx, y+dy
					if nx >= 0 && ny >= 0 && nx < w && ny < h && own[labels[ny*w+nx]] {
						near = true
						break
					}
				}
			}
			if !near {
				continue
			}
			out.Set(x-crop.Min.X, y-crop.Min.Y, img.At(x+b.Min.X, y+b.Min.Y))
		}
	}
	// Pixels not copied stay transparent black; make them white before keying.
	for i := 0; i < len(out.Pix); i += 4 {
		if out.Pix[i+3] == 0 {
			out.Pix[i], out.Pix[i+1], out.Pix[i+2], out.Pix[i+3] = 255, 255, 255, 255
		}
	}
	return MakeTransparent(out, thr).(*image.NRGBA)
}

func toGray(img image.Image) *image.Gray {
	b := img.Bounds()
	g := image.NewGray(image.Rect(0, 0, b.Dx(), b.Dy()))
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			c := color.NRGBAModel.Convert(img.At(x, y)).(color.NRGBA)
			// Composite on white so transparent input reads as paper.
			a := int(c.A)
			lum := (299*int(c.R) + 587*int(c.G) + 114*int(c.B)) / 1000
			g.Pix[(y-b.Min.Y)*g.Stride+(x-b.Min.X)] = uint8((lum*a + 255*(255-a)) / 255)
		}
	}
	return g
}

// otsu returns the threshold that best separates ink from paper.
func otsu(g *image.Gray) int {
	var hist [256]int
	for _, v := range g.Pix {
		hist[v]++
	}
	total := len(g.Pix)
	var sumAll float64
	for i, n := range hist {
		sumAll += float64(i * n)
	}
	var sumB, wB float64
	best, bestVar := 128, -1.0
	for t := 0; t < 256; t++ {
		wB += float64(hist[t])
		if wB == 0 {
			continue
		}
		wF := float64(total) - wB
		if wF == 0 {
			break
		}
		sumB += float64(t * hist[t])
		mB := sumB / wB
		mF := (sumAll - sumB) / wF
		v := wB * wF * (mB - mF) * (mB - mF)
		if v > bestVar {
			bestVar, best = v, t+1
		}
	}
	return best
}

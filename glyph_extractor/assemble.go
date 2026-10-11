package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"image"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"golang.org/x/text/unicode/norm"
)

// LabelsFile is labels.json written by tools/sheets/label.html: candidate id
// → character, or null for a skipped candidate.
type LabelsFile struct {
	Version int                `json:"version"`
	Labels  map[string]*string `json:"labels"`
}

// ComposeTable lists how Czech accented letters are built from a base glyph
// and an accent glyph (plan A6). "ı" is the dotless i, derived from "i"
// when a sheet has none.
var ComposeTable = map[string][2]string{
	"Á": {"A", "acute"}, "Č": {"C", "caron"}, "Ď": {"D", "caron"}, "É": {"E", "acute"},
	"Ě": {"E", "caron"}, "Í": {"I", "acute"}, "Ň": {"N", "caron"}, "Ó": {"O", "acute"},
	"Ř": {"R", "caron"}, "Š": {"S", "caron"}, "Ť": {"T", "caron"}, "Ú": {"U", "acute"},
	"Ů": {"U", "ring"}, "Ý": {"Y", "acute"}, "Ž": {"Z", "caron"},
	"á": {"a", "acute"}, "č": {"c", "caron"}, "ď": {"d", "caron"}, "é": {"e", "acute"},
	"ě": {"e", "caron"}, "í": {"ı", "acute"}, "ň": {"n", "caron"}, "ó": {"o", "acute"},
	"ř": {"r", "caron"}, "š": {"s", "caron"}, "ť": {"t", "caron"}, "ú": {"u", "acute"},
	"ů": {"u", "ring"}, "ý": {"y", "acute"}, "ž": {"z", "caron"},
}

func runAssemble(args []string) error {
	fs := flag.NewFlagSet("assemble", flag.ContinueOnError)
	meta := SheetMeta{Source: "handwriting"}
	var labelsPath, output, accents string
	var variants, padding, dpi int
	fs.StringVar(&labelsPath, "labels", "", "labels.json from tools/sheets/label.html (overrides labels in candidates.json)")
	fs.StringVar(&output, "output", "", "Sheet directory to write (required)")
	fs.IntVar(&variants, "variants", 5, "Maximum variants kept per character")
	fs.IntVar(&padding, "padding", 2, "Transparent padding of the candidate PNGs")
	fs.IntVar(&dpi, "dpi", 0, "Sheet DPI (default: the DPI in candidates.json, else 300)")
	fs.StringVar(&accents, "accents", "", "Sheet directory with caron/acute/ring glyphs to compose Czech letters (e.g. assets/glyphs/_accents)")
	meta.addFlags(fs)
	fs.Usage = func() {
		fmt.Println("Usage: glyph_extractor assemble [flags] <candidates.json>")
		fs.PrintDefaults()
	}
	if err := fs.Parse(positionalLast(args)); err != nil {
		return err
	}
	if fs.NArg() != 1 || output == "" {
		fs.Usage()
		return fmt.Errorf("expected candidates.json and -output")
	}
	meta.resolve(output)
	return assembleSheet(fs.Arg(0), labelsPath, output, accents, meta, variants, padding, dpi)
}

func assembleSheet(candPath, labelsPath, output, accentsDir string, meta SheetMeta, maxVariants, padding, dpi int) error {
	data, err := os.ReadFile(candPath)
	if err != nil {
		return err
	}
	var cf CandidatesFile
	if err := json.Unmarshal(data, &cf); err != nil {
		return fmt.Errorf("parsing %s: %w", candPath, err)
	}
	var overrides map[string]*string
	if labelsPath != "" {
		data, err := os.ReadFile(labelsPath)
		if err != nil {
			return err
		}
		var lf LabelsFile
		if err := json.Unmarshal(data, &lf); err != nil {
			return fmt.Errorf("parsing %s: %w", labelsPath, err)
		}
		overrides = lf.Labels
	}
	if dpi == 0 {
		dpi = cf.DPI
	}
	if dpi == 0 {
		dpi = 300
	}

	// Group labelled candidates by character, keeping candidate order.
	byLabel := map[string][]Candidate{}
	var labelOrder []string
	for _, c := range cf.Candidates {
		label := c.Label
		if o, ok := overrides[fmt.Sprint(c.ID)]; ok {
			label = ""
			if o != nil {
				label = *o
			}
		}
		label = norm.NFC.String(strings.TrimSpace(label))
		if label == "" {
			continue
		}
		if _, seen := byLabel[label]; !seen {
			labelOrder = append(labelOrder, label)
		}
		byLabel[label] = append(byLabel[label], c)
	}
	if len(byLabel) == 0 {
		return fmt.Errorf("no labelled candidates (label them with tools/sheets/label.html)")
	}

	sb := meta.builder(dpi)
	base := filepath.Dir(candPath)
	for _, label := range labelOrder {
		cands := byLabel[label]
		if len(cands) > maxVariants {
			cands = cands[:maxVariants]
		}
		for _, c := range cands {
			img, err := loadImage(filepath.Join(base, c.File))
			if err != nil {
				return fmt.Errorf("candidate %d: %w", c.ID, err)
			}
			g := toNRGBA(img)
			gb := g.Bounds()
			if gb.Min != (image.Point{}) {
				g = cropToOrigin(g)
				gb = g.Bounds()
			}
			var baseline int
			if c.Baseline != nil {
				// bbox is the PNG in source pixels; tolerate PNGs padded
				// symmetrically around an ink-only bbox.
				offY := (gb.Dy() - (c.BBox[3] - c.BBox[1])) / 2
				baseline = *c.Baseline - c.BBox[1] + offY
			} else {
				baseline = estimateBaseline(label, gb.Dy(), padding)
			}
			sb.Add(SheetGlyph{Key: label, Image: g, Row: -1, Metrics: GlyphMetrics{
				Width: gb.Dx(), Height: gb.Dy(), Baseline: baseline,
			}})
		}
	}

	s := sb.NormalizeCapHeight(meta.CapRatio, padding, "H", "E", "T", "L", "I")
	if s == 1 && meta.CapRatio > 0 {
		// No capitals (e.g. a lowercase-only sample): x-height ≈ 0.68 × cap height.
		s = sb.NormalizeCapHeight(meta.CapRatio*0.68, padding, "x", "n", "u", "o", "v", "z", "a", "e")
	}
	if s != 1 {
		fmt.Printf("Normalised size: scale %.3f\n", s)
	}

	if accentsDir != "" {
		if err := sb.importAccents(accentsDir); err != nil {
			return err
		}
	}
	sb.addComposeRules(padding)

	if err := sb.Write(output); err != nil {
		return err
	}
	if len(sb.Manifest.Compose) > 0 {
		keys := make([]string, 0, len(sb.Manifest.Compose))
		for k := range sb.Manifest.Compose {
			keys = append(keys, k)
		}
		sort.Strings(keys)
		fmt.Printf("Composed %d letters: %s\n", len(keys), strings.Join(keys, " "))
	}
	fmt.Printf("%s: %s → %s\n", meta.ID, sb.Summary(), output)
	return nil
}

// estimateBaseline guesses where the baseline lies inside an isolated glyph
// image (datasets have no text line). Most characters sit on it; the others
// extend below by a typical proportion of their ink height.
func estimateBaseline(label string, h, padding int) int {
	ink := float64(h - 2*padding)
	at := func(f float64) int { return padding + int(ink*f+0.5) }
	switch label {
	case "g", "j", "p", "q", "y", "ý", "ç", "µ":
		return at(0.65)
	case ",", "‚", "„":
		return at(0.40)
	case ";":
		return at(0.72)
	case "(", ")", "[", "]", "{", "}", "|", "/", "\\", "§":
		return at(0.82)
	case "_":
		return padding
	}
	return h - padding
}

// importAccents copies caron/acute/ring glyphs from another sheet, scaled
// from that sheet's em to this one.
func (sb *SheetBuilder) importAccents(dir string) error {
	m, err := ReadManifest(dir)
	if err != nil {
		return fmt.Errorf("accents: %w", err)
	}
	have := sb.keys()
	scale := 1.0
	if m.EmHeight > 0 {
		scale = float64(sb.Manifest.EmHeight) / float64(m.EmHeight)
	}
	for _, key := range AccentKeys {
		if have[key] > 0 {
			continue
		}
		for i, file := range m.Glyphs[key] {
			img, err := loadImage(filepath.Join(dir, file))
			if err != nil {
				return err
			}
			var met GlyphMetrics
			if i < len(m.Metrics[key]) {
				met = m.Metrics[key][i]
			}
			g := SheetGlyph{Key: key, Image: toNRGBA(img), Metrics: met, Row: -1}
			tmp := &SheetBuilder{glyphs: []SheetGlyph{g}}
			tmp.Scale(scale)
			sb.Add(tmp.glyphs[0])
		}
	}
	return nil
}

// addComposeRules declares compose entries for Czech letters the sheet lacks
// but can build from a base letter and an accent glyph. A dotless i is cut
// from "i" when needed.
func (sb *SheetBuilder) addComposeRules(padding int) {
	have := sb.keys()
	if have["ı"] == 0 && have["i"] > 0 && have["acute"] > 0 && have["í"] == 0 {
		for _, g := range append([]SheetGlyph(nil), sb.glyphs...) {
			if g.Key != "i" {
				continue
			}
			if dl, ok := removeDot(g.Image); ok {
				sb.Add(SheetGlyph{Key: "ı", Image: dl, Metrics: g.Metrics})
			}
		}
		have = sb.keys()
	}
	for char, parts := range ComposeTable {
		if have[char] > 0 || have[parts[1]] == 0 {
			continue
		}
		baseKey := parts[0]
		if have[baseKey] == 0 && baseKey == "ı" {
			baseKey = "i"
		}
		if have[baseKey] == 0 {
			continue
		}
		if sb.Manifest.Compose == nil {
			sb.Manifest.Compose = map[string][]string{}
		}
		sb.Manifest.Compose[char] = []string{baseKey, parts[1]}
	}
}

func (sb *SheetBuilder) keys() map[string]int {
	have := map[string]int{}
	for _, g := range sb.glyphs {
		have[g.Key]++
	}
	return have
}

// removeDot erases the topmost small component (the tittle) of an i glyph.
// The image keeps its size so metrics stay valid.
func removeDot(img *image.NRGBA) (*image.NRGBA, bool) {
	labels, comps := connectedComponents(img, 128)
	if len(comps) < 2 {
		return nil, false
	}
	top, stem := -1, -1
	for i, c := range comps {
		if stem < 0 || c.area > comps[stem].area {
			stem = i
		}
	}
	for i, c := range comps {
		if i != stem && c.bounds.Max.Y <= comps[stem].bounds.Min.Y+2 && (top < 0 || c.bounds.Min.Y < comps[top].bounds.Min.Y) {
			top = i
		}
	}
	if top < 0 {
		return nil, false
	}
	out := image.NewNRGBA(img.Bounds())
	copy(out.Pix, img.Pix)
	// Clear the dot and its anti-aliased fringe.
	r := comps[top].bounds.Inset(-2)
	w := img.Bounds().Dx()
	for y := max(0, r.Min.Y); y < min(img.Bounds().Dy(), r.Max.Y); y++ {
		for x := max(0, r.Min.X); x < min(w, r.Max.X); x++ {
			if labels[y*w+x] != int32(stem+1) {
				out.Pix[y*out.Stride+x*4+3] = 0
			}
		}
	}
	return out, true
}

func cropToOrigin(img *image.NRGBA) *image.NRGBA {
	b := img.Bounds()
	out := image.NewNRGBA(image.Rect(0, 0, b.Dx(), b.Dy()))
	for y := 0; y < b.Dy(); y++ {
		copy(out.Pix[y*out.Stride:y*out.Stride+b.Dx()*4], img.Pix[y*img.Stride:y*img.Stride+b.Dx()*4])
	}
	return out
}

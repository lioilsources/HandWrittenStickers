package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
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
	// Entry and Exit are where the pen stroke of a joined (cursive) letter
	// comes in on the left and leaves on the right; nil when the letter
	// does not join on that side. See joins.go.
	Entry *JoinPoint `json:"entry,omitempty"`
	Exit  *JoinPoint `json:"exit,omitempty"`
}

// JoinPoint is [x, y, direction]: a point in PNG pixels and the direction
// the pen travels through it in degrees (0 = to the right, 90 = up).
type JoinPoint [3]int

func (p *JoinPoint) scaled(s float64) *JoinPoint {
	if p == nil {
		return nil
	}
	return &JoinPoint{int(float64(p[0])*s + 0.5), int(float64(p[1])*s + 0.5), p[2]}
}

// Scaled returns the metrics multiplied by s (used by size normalisation).
func (m GlyphMetrics) Scaled(s float64) GlyphMetrics {
	r := func(v int) int { return int(float64(v)*s + 0.5) }
	return GlyphMetrics{
		Width: r(m.Width), Height: r(m.Height), Baseline: r(m.Baseline),
		Advance: r(m.Advance), Bearing: r(m.Bearing),
		Entry: m.Entry.scaled(s), Exit: m.Exit.scaled(s),
	}
}

// OneOrMany is a JSON value that is written as a single value when it has
// one element and as an array otherwise. Manifest v1/v2 store one file per
// character ("a": "a.png"); v3 adds variants ("a": ["a.png", "a_1.png"]).
// Both forms are accepted when reading.
type OneOrMany[T any] []T

func (o OneOrMany[T]) MarshalJSON() ([]byte, error) {
	if len(o) == 1 {
		return json.Marshal(o[0])
	}
	return json.Marshal([]T(o))
}

func (o *OneOrMany[T]) UnmarshalJSON(data []byte) error {
	var many []T
	if err := json.Unmarshal(data, &many); err == nil {
		*o = many
		return nil
	}
	var one T
	if err := json.Unmarshal(data, &one); err != nil {
		return err
	}
	*o = OneOrMany[T]{one}
	return nil
}

// ManifestV2 is the glyph sheet manifest (glyphs.json). It is a superset of
// all versions:
//   - v1: version, cellSize, glyphs (one file per character, untrimmed cells)
//   - v2: adds id … baselineRatio and per-glyph metrics
//   - v3: glyphs/metrics may hold arrays (variants), plus colored, compose
//     and fallback
//
// Readers that only know v2 keep working with v3 sheets that have no
// variants, because single-element lists are written as plain values.
type ManifestV2 struct {
	Version       int                                `json:"version"`
	ID            string                             `json:"id,omitempty"`
	Name          string                             `json:"name,omitempty"`
	Source        string                             `json:"source,omitempty"` // "font", "handwriting", "material", "dataset", …
	License       string                             `json:"license,omitempty"`
	Attribution   string                             `json:"attribution,omitempty"`
	CellSize      CellSize                           `json:"cellSize"`
	DPI           int                                `json:"dpi,omitempty"`
	EmHeight      int                                `json:"emHeight,omitempty"`      // nominal em size in px
	BaselineRatio float64                            `json:"baselineRatio,omitempty"` // baseline position within a cell (0..1 from top)
	Colored       bool                               `json:"colored,omitempty"`       // glyphs carry their own colours; renderer must not tint them
	Fallback      string                             `json:"fallback,omitempty"`      // sheet id used for characters this sheet lacks
	Compose       map[string][]string                `json:"compose,omitempty"`       // "č": ["c", "caron"] – build from base + accent glyphs
	XHeight       float64                            `json:"xHeight,omitempty"`       // px, height of lowercase letters without ascenders
	SlantDeg      float64                            `json:"slantDeg,omitempty"`      // slant of the writing, positive = leaning right
	StrokeWidth   float64                            `json:"strokeWidth,omitempty"`   // px, pen width; set when letters carry entry/exit points
	InkColor      string                             `json:"inkColor,omitempty"`      // #rrggbb of the pen, for the strokes joining letters
	Glyphs        map[string]OneOrMany[string]       `json:"glyphs"`
	Metrics       map[string]OneOrMany[GlyphMetrics] `json:"metrics,omitempty"`
}

// Accent glyph keys that may appear in glyphs/compose next to real characters.
var AccentKeys = []string{"caron", "acute", "ring"}

// NewManifest returns an empty manifest with the paper template geometry.
func NewManifest(id, name, source string, dpi int) *ManifestV2 {
	return &ManifestV2{
		Version:       2,
		ID:            id,
		Name:          name,
		Source:        source,
		CellSize:      CellSize{Width: 22.5, Height: 26.2},
		DPI:           dpi,
		BaselineRatio: 0.75,
		Glyphs:        map[string]OneOrMany[string]{},
		Metrics:       map[string]OneOrMany[GlyphMetrics]{},
	}
}

// Add appends one glyph variant.
func (m *ManifestV2) Add(char, file string, metrics GlyphMetrics) {
	m.Glyphs[char] = append(m.Glyphs[char], file)
	m.Metrics[char] = append(m.Metrics[char], metrics)
}

// Write stores the manifest as <dir>/glyphs.json, bumping the version to 3
// when v3-only features are used.
func (m *ManifestV2) Write(dir string) error {
	if m.Version < 3 && m.usesV3() {
		m.Version = 3
	}
	data, err := json.MarshalIndent(m, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(dir, "glyphs.json"), data, 0644)
}

func (m *ManifestV2) usesV3() bool {
	if m.Colored || m.Fallback != "" || len(m.Compose) > 0 || m.StrokeWidth > 0 {
		return true
	}
	for _, files := range m.Glyphs {
		if len(files) > 1 {
			return true
		}
	}
	return false
}

// ReadManifest loads <dir>/glyphs.json.
func ReadManifest(dir string) (*ManifestV2, error) {
	data, err := os.ReadFile(filepath.Join(dir, "glyphs.json"))
	if err != nil {
		return nil, err
	}
	var m ManifestV2
	if err := json.Unmarshal(data, &m); err != nil {
		return nil, fmt.Errorf("parsing %s/glyphs.json: %w", dir, err)
	}
	if m.Glyphs == nil {
		m.Glyphs = map[string]OneOrMany[string]{}
	}
	if m.Metrics == nil {
		m.Metrics = map[string]OneOrMany[GlyphMetrics]{}
	}
	return &m, nil
}

// VariantFilename returns the PNG name of variant i of r: "a.png", "a_1.png", …
func VariantFilename(key string, i int) string {
	if i == 0 {
		return key + ".png"
	}
	return fmt.Sprintf("%s_%d.png", key, i)
}

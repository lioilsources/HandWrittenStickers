package main

import (
	"flag"
	"fmt"
	"image"
	"path/filepath"
	"strings"
)

// ExtractOptions configures template-grid extraction (the --input mode).
type ExtractOptions struct {
	Inputs     []string
	OutputDir  string
	Meta       SheetMeta
	DPI        int
	MarginTop  float64
	MarginLeft float64
	Cell       CellOptions
	// FitBaseline locates the written baseline per row instead of trusting
	// the template guide (see SheetBuilder.FitRowBaselines).
	FitBaseline bool
	// AutoGrid finds the printed grid in each photo instead of assuming an
	// aligned 300 DPI scan with fixed margins.
	AutoGrid bool
}

// SheetMeta holds the manifest fields shared by every command that writes a
// sheet (extract, upgrade, assemble).
type SheetMeta struct {
	ID, Name, Source, Fallback, License, Attribution string
	CapRatio                                         float64
	Colored                                          bool
}

func (m *SheetMeta) addFlags(fs *flag.FlagSet) {
	fs.StringVar(&m.ID, "id", "", "Sheet id stored in the manifest (defaults to the output directory name)")
	fs.StringVar(&m.Name, "name", "", "Human readable sheet name (defaults to id)")
	fs.StringVar(&m.Source, "source", m.Source, "Manifest source: handwriting, material, dataset, archive, …")
	fs.StringVar(&m.Fallback, "fallback", "", "Sheet id the app uses for characters this sheet lacks (e.g. caveat)")
	fs.StringVar(&m.License, "license", "", "License identifier stored in the manifest")
	fs.StringVar(&m.Attribution, "attribution", "", "Attribution line stored in the manifest")
	fs.Float64Var(&m.CapRatio, "cap-ratio", 0.70, "Normalise so the capital H is this fraction of the em (0 disables)")
	fs.BoolVar(&m.Colored, "colored", false, "Glyphs are coloured (material letters); the app must not tint them")
}

// resolve fills defaults once the output directory is known.
func (m *SheetMeta) resolve(outputDir string) {
	m.ID = defaultID(m.ID, outputDir)
	if m.Name == "" {
		m.Name = m.ID
	}
}

// builder creates a SheetBuilder carrying the metadata.
func (m SheetMeta) builder(dpi int) *SheetBuilder {
	sb := NewSheetBuilder(m.ID, m.Name, m.Source, dpi)
	sb.Manifest.Colored = m.Colored
	sb.Manifest.Fallback = m.Fallback
	sb.Manifest.License = m.License
	sb.Manifest.Attribution = m.Attribution
	return sb
}

// addKeyFlags registers background-removal flags.
func addKeyFlags(fs *flag.FlagSet, mode, bgColor *string, threshold *int, tolerance *float64) {
	fs.StringVar(mode, "bg-mode", string(BgLightness), "Background removal: lightness (ink on paper), chroma (colour distance), alpha (keep PNG alpha)")
	fs.StringVar(bgColor, "bg-color", "", "Reference background #rrggbb for -bg-mode chroma (default: sampled from cell corners)")
	fs.IntVar(threshold, "threshold", 160, "White threshold (0-255) for -bg-mode lightness")
	fs.Float64Var(tolerance, "bg-tolerance", 12, "ΔE (CIE Lab) below which a pixel is background for -bg-mode chroma")
}

func buildKeyOptions(mode, bgColor string, threshold int, tolerance float64) (KeyOptions, error) {
	m, err := ParseBgMode(mode)
	if err != nil {
		return KeyOptions{}, err
	}
	k := KeyOptions{Mode: m, Threshold: uint8(threshold), Tolerance: tolerance}
	if bgColor != "" {
		c, err := ParseHexColor(bgColor)
		if err != nil {
			return KeyOptions{}, err
		}
		k.BgColor = &c
	}
	return k, nil
}

// charsetIndex returns the template position of a character, or -1.
func charsetIndex(key string) int {
	for i, r := range Charset {
		if string(r) == key {
			return i
		}
	}
	return -1
}

// positionalLast moves a leading positional argument behind the flags, so
// both `cmd DIR -flag x` and `cmd -flag x DIR` work with package flag.
func positionalLast(args []string) []string {
	if len(args) > 0 && !strings.HasPrefix(args[0], "-") {
		return append(append([]string(nil), args[1:]...), args[0])
	}
	return args
}

func defaultID(id, outputDir string) string {
	if id != "" {
		return id
	}
	return filepath.Base(filepath.Clean(outputDir))
}

// runExtract parses the --input mode flags.
func runExtract(args []string) error {
	fs := flag.NewFlagSet("extract", flag.ContinueOnError)
	var inputs, mode, bgColor string
	var threshold int
	var tolerance float64
	opts := ExtractOptions{Meta: SheetMeta{Source: "handwriting"}, Cell: DefaultCellOptions()}
	fs.StringVar(&inputs, "input", "", "Input images (comma-separated, one per template page, e.g. page1.png,page2.png)")
	fs.StringVar(&opts.OutputDir, "output", "./output", "Sheet directory (PNGs + glyphs.json)")
	fs.IntVar(&opts.DPI, "dpi", 300, "Scan DPI")
	fs.Float64Var(&opts.MarginTop, "margin-top", 15.0, "Top margin in mm")
	fs.Float64Var(&opts.MarginLeft, "margin-left", 15.0, "Left margin in mm")
	fs.IntVar(&opts.Cell.Padding, "padding", 2, "Transparent padding in px kept around the ink")
	grid := fs.String("grid", "template", "Cell positions: template (aligned scan, fixed margins) or auto (detect the printed grid lines in a photo)")
	fs.BoolVar(&opts.FitBaseline, "fit-baseline", true, "Fit the written baseline per template row instead of using the printed guide")
	addKeyFlags(fs, &mode, &bgColor, &threshold, &tolerance)
	opts.Meta.addFlags(fs)
	if err := fs.Parse(args); err != nil {
		return err
	}
	if inputs == "" {
		printUsage()
		fs.PrintDefaults()
		return fmt.Errorf("-input is required")
	}
	key, err := buildKeyOptions(mode, bgColor, threshold, tolerance)
	if err != nil {
		return err
	}
	opts.Cell.Key = key
	switch *grid {
	case "template":
	case "auto":
		opts.AutoGrid = true
	default:
		return fmt.Errorf("unknown -grid %q (template|auto)", *grid)
	}
	for _, f := range strings.Split(inputs, ",") {
		opts.Inputs = append(opts.Inputs, strings.TrimSpace(f))
	}
	opts.Meta.resolve(opts.OutputDir)
	return extractSheet(opts)
}

// extractSheet cuts every template cell out of the page images, trims it to
// the ink and writes a v2 sheet with baseline metrics. The template baseline
// guide sits at 75 % of the cell height, so baseline = 0.75·cellH − crop top.
func extractSheet(opts ExtractOptions) error {
	config := GridConfig{
		CellWidthMM:  22.5,
		CellHeightMM: 26.2,
		Columns:      8,
		Rows:         10,
		DPI:          opts.DPI,
		MarginTopMM:  opts.MarginTop,
		MarginLeftMM: opts.MarginLeft,
	}
	sb := opts.Meta.builder(opts.DPI)
	baselineY := int(float64(config.CellHeightPx())*sb.Manifest.BaselineRatio + 0.5)

	charIndex := 0
	for pageIndex, inputFile := range opts.Inputs {
		img, err := loadImage(inputFile)
		if err != nil {
			return fmt.Errorf("loading %s: %w", inputFile, err)
		}
		fmt.Printf("Page %d: %s (%dx%d px, cell %dx%d px)\n", pageIndex+1, inputFile,
			img.Bounds().Dx(), img.Bounds().Dy(), config.CellWidthPx(), config.CellHeightPx())
		var grid DetectedGrid
		if opts.AutoGrid {
			var ok bool
			if grid, ok = DetectGrid(img, config.Columns, config.Rows); !ok {
				return fmt.Errorf("%s: no %dx%d grid found (straighten it with the Grid Alignment tool and use -grid template)",
					inputFile, config.Columns, config.Rows)
			}
			fmt.Printf("  grid: x %.0f…%.0f, y %.0f…%.0f px\n", grid.XTop[0], grid.XTop[config.Columns],
				grid.YLeft[0], grid.YLeft[config.Rows])
		}

		for row := 0; row < config.Rows; row++ {
			for col := 0; col < config.Columns; col++ {
				if charIndex >= len(Charset) {
					break
				}
				char := Charset[charIndex]
				charIndex++

				var cell image.Image
				if opts.AutoGrid {
					cell = grid.ExtractCellQuad(img, col, row, config.CellWidthPx(), config.CellHeightPx())
				} else {
					cell = config.ExtractCell(img, row, col)
				}
				glyph, rect, ok := ProcessCell(cell, opts.Cell)
				if !ok {
					fmt.Printf("  [%d,%d] '%c' empty cell, skipped\n", row, col, char)
					continue
				}
				sb.Add(SheetGlyph{
					Key:     string(char),
					Image:   glyph,
					Metrics: CellMetrics(rect, baselineY),
					Row:     (charIndex - 1) / config.Columns,
				})
			}
		}
	}

	if opts.FitBaseline {
		for _, l := range sb.FitRowBaselines(config.Rows, opts.Cell.Padding) {
			fmt.Println(l)
		}
	}
	if s := sb.NormalizeCapHeight(opts.Meta.CapRatio, opts.Cell.Padding, "H", "E", "T"); s != 1 {
		fmt.Printf("Normalised cap height: scale %.3f\n", s)
	}
	if err := sb.Write(opts.OutputDir); err != nil {
		return err
	}
	fmt.Printf("%s: %s → %s\n", opts.Meta.ID, sb.Summary(), opts.OutputDir)
	return nil
}

// runUpgrade converts a v1 sheet of untrimmed template cells (such as the
// original Laurinka sheet) into a v2 sheet with trimmed glyphs and metrics.
func runUpgrade(args []string) error {
	fs := flag.NewFlagSet("upgrade", flag.ContinueOnError)
	var output, mode, bgColor string
	var threshold int
	var tolerance float64
	meta := SheetMeta{Source: "handwriting"}
	cell := DefaultCellOptions()
	fs.StringVar(&output, "output", "", "Output sheet directory (default: overwrite the input sheet)")
	fs.IntVar(&cell.Padding, "padding", 2, "Transparent padding in px kept around the ink")
	fitBaseline := fs.Bool("fit-baseline", true, "Fit the written baseline per template row instead of using the guide at 75 %")
	addKeyFlags(fs, &mode, &bgColor, &threshold, &tolerance)
	meta.addFlags(fs)
	fs.Usage = func() {
		fmt.Println("Usage: glyph_extractor upgrade [flags] <v1_sheet_dir>")
		fs.PrintDefaults()
	}
	// Default to the alpha already present in the v1 PNGs.
	if err := fs.Parse(append([]string{"-bg-mode", "alpha"}, positionalLast(args)...)); err != nil {
		return err
	}
	if fs.NArg() != 1 {
		fs.Usage()
		return fmt.Errorf("expected one sheet directory")
	}
	in := fs.Arg(0)
	if output == "" {
		output = in
	}
	key, err := buildKeyOptions(mode, bgColor, threshold, tolerance)
	if err != nil {
		return err
	}
	cell.Key = key

	old, err := ReadManifest(in)
	if err != nil {
		return err
	}
	dpi := old.DPI
	if dpi == 0 {
		dpi = 300
	}
	inherit := func(v *string, old string) {
		if *v == "" {
			*v = old
		}
	}
	inherit(&meta.ID, old.ID)
	inherit(&meta.Name, old.Name)
	inherit(&meta.Fallback, old.Fallback)
	inherit(&meta.License, old.License)
	inherit(&meta.Attribution, old.Attribution)
	if old.Source != "" && meta.Source == "handwriting" {
		meta.Source = old.Source
	}
	meta.Colored = meta.Colored || old.Colored
	meta.resolve(output)
	sb := meta.builder(dpi)

	// Load everything first: output may be the input directory.
	type loaded struct {
		key string
		img image.Image
	}
	var cells []loaded
	for _, r := range Charset {
		files := old.Glyphs[string(r)]
		if len(files) == 0 {
			continue
		}
		img, err := loadImage(filepath.Join(in, files[0]))
		if err != nil {
			fmt.Printf("  SKIP '%c': %v\n", r, err)
			continue
		}
		cells = append(cells, loaded{string(r), img})
	}
	for _, c := range cells {
		row := charsetIndex(c.key) / 8
		baselineY := int(float64(c.img.Bounds().Dy())*sb.Manifest.BaselineRatio + 0.5)
		glyph, rect, ok := ProcessCell(c.img, cell)
		if !ok {
			fmt.Printf("  '%s' empty, skipped\n", c.key)
			continue
		}
		sb.Add(SheetGlyph{Key: c.key, Image: glyph, Metrics: CellMetrics(rect, baselineY), Row: row})
	}
	if *fitBaseline {
		for _, l := range sb.FitRowBaselines(10, cell.Padding) {
			fmt.Println(l)
		}
	}
	if s := sb.NormalizeCapHeight(meta.CapRatio, cell.Padding, "H", "E", "T"); s != 1 {
		fmt.Printf("Normalised cap height: scale %.3f\n", s)
	}
	if err := sb.Write(output); err != nil {
		return err
	}
	fmt.Printf("%s: %s → %s\n", meta.ID, sb.Summary(), output)
	return nil
}

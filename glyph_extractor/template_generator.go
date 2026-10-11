package main

import (
	"flag"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strings"

	"github.com/jung-kurt/gofpdf"
)

// TemplateConfig holds configuration for the template
type TemplateConfig struct {
	CellWidthMM  float64 // 22.5 mm
	CellHeightMM float64 // 26.2 mm
	Columns      int     // 8
	Rows         int     // 10
	MarginTopMM  float64 // Top margin
	MarginLeftMM float64 // Left margin
	FontSize     float64 // Font size for labels
}

func DefaultTemplateConfig() TemplateConfig {
	return TemplateConfig{
		CellWidthMM:  22.5,
		CellHeightMM: 26.2,
		Columns:      8,
		Rows:         10,
		MarginTopMM:  15.0,
		MarginLeftMM: 15.0,
		FontSize:     8,
	}
}

func generateTemplate(outputPath string) error {
	config := DefaultTemplateConfig()

	// Create PDF (A4: 210 x 297 mm)
	pdf := gofpdf.New("P", "mm", "A4", "")

	// Add UTF-8 font for full Unicode support
	// Note: gofpdf has issues with absolute paths, using relative path from cwd
	pdf.AddUTF8Font("DejaVu", "", "fonts/DejaVuSans.ttf")
	pdf.AddUTF8Font("DejaVu", "B", "fonts/DejaVuSans.ttf")
	pdf.AddUTF8Font("DejaVu", "I", "fonts/DejaVuSans.ttf")

	// Page 1
	pdf.AddPage()
	drawGrid(pdf, config, Charset[:80], "Strana 1 - Velká písmena, čísla, interpunkce")

	// Page 2
	pdf.AddPage()
	drawGrid(pdf, config, Charset[80:], "Strana 2 - Malá písmena, speciální znaky")

	return pdf.OutputFileAndClose(outputPath)
}

func drawGrid(pdf *gofpdf.Fpdf, config TemplateConfig, chars []rune, title string) {
	// Title
	pdf.SetFont("DejaVu", "B", 12)
	pdf.SetXY(config.MarginLeftMM, 5)
	pdf.Cell(0, 10, title)

	// Set up for grid
	pdf.SetFont("DejaVu", "", config.FontSize)
	pdf.SetDrawColor(180, 180, 180) // Light gray lines
	pdf.SetLineWidth(0.3)

	charIndex := 0

	for row := 0; row < config.Rows; row++ {
		for col := 0; col < config.Columns; col++ {
			x := config.MarginLeftMM + float64(col)*config.CellWidthMM
			y := config.MarginTopMM + float64(row)*config.CellHeightMM

			// Draw cell border
			pdf.Rect(x, y, config.CellWidthMM, config.CellHeightMM, "D")

			// Draw character label in top-left corner
			if charIndex < len(chars) {
				char := chars[charIndex]
				label := string(char)

				// Handle special characters for display
				switch char {
				case ' ':
					label = "SP"
				case '\t':
					label = "TAB"
				case '\n':
					label = "NL"
				}

				pdf.SetTextColor(150, 150, 150) // Gray text
				pdf.SetXY(x+1, y+1)
				pdf.Cell(0, 0, label)
				pdf.SetTextColor(0, 0, 0) // Reset to black

				charIndex++
			}
		}
	}

	// Draw baseline guide (dashed line at ~70% height of each cell)
	pdf.SetDrawColor(200, 200, 255) // Light blue
	pdf.SetLineWidth(0.2)

	baselineOffset := config.CellHeightMM * 0.75

	for row := 0; row < config.Rows; row++ {
		y := config.MarginTopMM + float64(row)*config.CellHeightMM + baselineOffset
		x1 := config.MarginLeftMM
		x2 := config.MarginLeftMM + float64(config.Columns)*config.CellWidthMM

		// Draw dashed line
		dashLen := 2.0
		gapLen := 1.0
		for x := x1; x < x2; x += dashLen + gapLen {
			endX := x + dashLen
			if endX > x2 {
				endX = x2
			}
			pdf.Line(x, y, endX, y)
		}
	}

	// Footer with info
	pdf.SetFont("DejaVu", "I", 8)
	pdf.SetTextColor(128, 128, 128)
	pdf.SetXY(config.MarginLeftMM, 285)
	pdf.Cell(0, 0, fmt.Sprintf("Políčko: %.1f × %.1f mm | Mřížka: %d × %d | Modrá čára = účaří",
		config.CellWidthMM, config.CellHeightMM, config.Columns, config.Rows))
}

// runTemplate dispatches the `template` command:
//
//	template [out.pdf]                              printable template to fill in
//	template -guide F.ttf -out p1.png,p2.png        guide sheets for material letters
//	template -pangram out.pdf                       lined sheet with text to trace
func runTemplate(args []string) error {
	fs := flag.NewFlagSet("template", flag.ContinueOnError)
	opts := DefaultGuideOptions()
	var guide, out, pangram string
	fs.StringVar(&guide, "guide", "", "Render guide sheets (PNG) with letters from this TTF/OTF instead of the PDF template")
	fs.StringVar(&out, "out", "guide_p1.png,guide_p2.png", "Guide page PNGs (comma-separated, one per page)")
	fs.StringVar(&opts.MaskPath, "mask", "", "Also write the cell grid as a mask PNG (white lines on black) for ControlNet")
	fs.IntVar(&opts.DPI, "dpi", opts.DPI, "Guide raster DPI")
	fs.Float64Var(&opts.CapRatio, "cap-ratio", opts.CapRatio, "Capital H height as a fraction of the em")
	fs.Float64Var(&opts.MaxFill, "max-fill", opts.MaxFill, "Max fraction of the cell a guide glyph may fill")
	fs.StringVar(&pangram, "pangram", "", "Write a lined pangram sheet to trace (PDF) and its transcript (.txt)")
	if err := fs.Parse(args); err != nil {
		return err
	}
	switch {
	case guide != "":
		opts.FontPath = guide
		for _, o := range strings.Split(out, ",") {
			opts.Outputs = append(opts.Outputs, strings.TrimSpace(o))
		}
		return generateGuide(opts)
	case pangram != "":
		return generatePangramSheet(pangram)
	default:
		path := "template.pdf"
		if fs.NArg() > 0 {
			path = fs.Arg(0)
		}
		fmt.Printf("Generating template: %s\n", path)
		return generateTemplate(path)
	}
}

// PangramLines is the text of the free-form handwriting sheet (plan S2).
// Every lowercase letter appears at least twice (segmented sheets get
// variants), every capital at least once; the last line covers digits and
// punctuation.
var PangramLines = []string{
	"Příliš žluťoučký kůň úpěl ďábelské ódy.",
	"Hleď, toť čarovný je loužek, kde hnědý",
	"fax a xylofon qwerty gumují.",
	"Nechť již hříšné saxofony ďáblů rozezvučí",
	"síň úděsnými tóny waltzu, tanga a quickstepu.",
	"PŘÍLIŠ ŽLUŤOUČKÝ KŮŇ ÚPĚL ĎÁBELSKÉ ÓDY!",
	"HLEĎ, TOŤ ČAROVNÝ JE LOUŽEK: FAX, QWERTY, GUMA.",
	"NECHŤ ZVĚŘ Ů Ň Ť Ó É Í Á Ý W X Q",
	"0 1 2 3 4 5 6 7 8 9 . , ! ? : ; - ( ) \" ' / @ # & + = % * € $",
}

// generatePangramSheet writes an A4 PDF with PangramLines printed in light
// grey on ruled lines (baseline + x-height), to be traced with a pen, and
// the transcript next to it for `segment -labels-file`. Characters are
// spaced apart so traced letters do not touch (segmentation needs gaps);
// long lines wrap at word boundaries and the sheet grows to more pages.
func generatePangramSheet(path string) error {
	const (
		left     = 15.0
		right    = 195.0
		top      = 34.0
		bottom   = 280.0
		pitch    = 25.0 // mm between baselines
		fontSize = 24.0 // pt
		gap      = 2.2  // mm extra space between characters
	)
	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddUTF8Font("DejaVu", "", "fonts/DejaVuSans.ttf")
	pdf.SetFont("DejaVu", "", fontSize)

	charW := func(r rune) float64 { return pdf.GetStringWidth(string(r)) }
	wordW := func(w string) float64 {
		var x float64
		for _, r := range w {
			x += charW(r) + gap
		}
		return x - gap
	}
	spaceW := charW(' ') + 3*gap

	// Wrap every source line into lines that fit the ruled width.
	var lines []string
	for _, src := range PangramLines {
		var cur []string
		var width float64
		for _, w := range strings.Fields(src) {
			ww := wordW(w)
			if len(cur) > 0 && width+spaceW+ww > right-left-4 {
				lines = append(lines, strings.Join(cur, " "))
				cur, width = nil, 0
			}
			if len(cur) > 0 {
				width += spaceW
			}
			cur = append(cur, w)
			width += ww
		}
		if len(cur) > 0 {
			lines = append(lines, strings.Join(cur, " "))
		}
	}

	xHeight := fontSize * 0.3528 * 0.55 // pt → mm × x-height of DejaVu
	perPage := int(math.Floor((bottom-top)/pitch)) + 1
	for i, line := range lines {
		if i%perPage == 0 {
			pdf.AddPage()
			pdf.SetFont("DejaVu", "", 10)
			pdf.SetTextColor(90, 90, 90)
			pdf.SetXY(left, 8)
			pdf.Cell(0, 6, fmt.Sprintf("Strana %d – obtáhněte šedý text perem, písmena nespojujte. Vyfoťte shora a zpracujte:", i/perPage+1))
			pdf.SetXY(left, 14)
			pdf.Cell(0, 6, "glyph_extractor segment -input foto.png -labels-file "+filepath.Base(strings.TrimSuffix(path, filepath.Ext(path)))+".txt")
			pdf.SetFont("DejaVu", "", fontSize)
		}
		baseline := top + float64(i%perPage)*pitch
		pdf.SetDrawColor(170, 190, 230)
		pdf.SetLineWidth(0.3)
		pdf.Line(left, baseline, right, baseline)
		pdf.SetDrawColor(215, 225, 245)
		pdf.SetLineWidth(0.2)
		pdf.Line(left, baseline-xHeight, right, baseline-xHeight)
		pdf.SetTextColor(205, 205, 205)
		x := left + 2
		for wi, w := range strings.Fields(line) {
			if wi > 0 {
				x += spaceW + gap
			}
			for ci, r := range w {
				if ci > 0 {
					x += gap
				}
				pdf.Text(x, baseline, string(r))
				x += charW(r)
			}
		}
	}
	if err := pdf.OutputFileAndClose(path); err != nil {
		return err
	}
	txt := strings.TrimSuffix(path, filepath.Ext(path)) + ".txt"
	if err := os.WriteFile(txt, []byte(strings.Join(lines, "\n")+"\n"), 0644); err != nil {
		return err
	}
	fmt.Printf("Pangram sheet → %s (%d lines, %d pages), transcript → %s\n",
		path, len(lines), (len(lines)+perPage-1)/perPage, txt)
	return nil
}

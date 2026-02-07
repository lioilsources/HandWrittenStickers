package main

import (
	"fmt"

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
	pdf.SetFont("Helvetica", "B", 12)
	pdf.SetXY(config.MarginLeftMM, 5)
	pdf.Cell(0, 10, title)

	// Set up for grid
	pdf.SetFont("Helvetica", "", config.FontSize)
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
	pdf.SetFont("Helvetica", "I", 8)
	pdf.SetTextColor(128, 128, 128)
	pdf.SetXY(config.MarginLeftMM, 285)
	pdf.Cell(0, 0, fmt.Sprintf("Policko: %.1f x %.1f mm | Mrizka: %d x %d | Modra cara = ucari",
		config.CellWidthMM, config.CellHeightMM, config.Columns, config.Rows))
}

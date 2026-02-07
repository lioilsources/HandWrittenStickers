package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"os"
	"path/filepath"
	"strings"
)

// GlyphsJSON represents the output JSON structure
type GlyphsJSON struct {
	Version  int               `json:"version"`
	CellSize CellSize          `json:"cellSize"`
	Glyphs   map[string]string `json:"glyphs"`
}

type CellSize struct {
	Width  float64 `json:"width"`
	Height float64 `json:"height"`
}

func main() {
	// Check for template command first
	if len(os.Args) > 1 && os.Args[1] == "template" {
		outputPath := "template.pdf"
		if len(os.Args) > 2 {
			outputPath = os.Args[2]
		}
		fmt.Printf("Generating template: %s\n", outputPath)
		if err := generateTemplate(outputPath); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("Done!")
		return
	}

	// Parse command line arguments
	var inputFiles string
	var outputDir string
	var dpi int
	var marginTop float64
	var marginLeft float64
	var threshold int
	var transparent bool

	flag.StringVar(&inputFiles, "input", "", "Input image files (comma-separated, e.g., page1.png,page2.png)")
	flag.StringVar(&outputDir, "output", "./output", "Output directory")
	flag.IntVar(&dpi, "dpi", 300, "Scanner DPI")
	flag.Float64Var(&marginTop, "margin-top", 15.0, "Top margin in mm")
	flag.Float64Var(&marginLeft, "margin-left", 15.0, "Left margin in mm")
	flag.IntVar(&threshold, "threshold", 240, "White threshold (0-255)")
	flag.BoolVar(&transparent, "transparent", true, "Make background transparent")
	flag.Parse()

	if inputFiles == "" {
		fmt.Println("Usage:")
		fmt.Println("  glyph_extractor template [output.pdf]     - Generate template PDF")
		fmt.Println("  glyph_extractor --input page1.png,page2.png [options]")
		fmt.Println("\nOptions:")
		flag.PrintDefaults()
		os.Exit(1)
	}

	// Split input files
	files := strings.Split(inputFiles, ",")
	for i := range files {
		files[i] = strings.TrimSpace(files[i])
	}

	// Create config
	config := GridConfig{
		CellWidthMM:  22.5,
		CellHeightMM: 26.2,
		Columns:      8,
		Rows:         10,
		DPI:          dpi,
		MarginTopMM:  marginTop,
		MarginLeftMM: marginLeft,
	}

	// Create output directories
	glyphsDir := filepath.Join(outputDir, "glyphs")
	if err := os.MkdirAll(glyphsDir, 0755); err != nil {
		fmt.Fprintf(os.Stderr, "Error creating output directory: %v\n", err)
		os.Exit(1)
	}

	// Process images
	glyphsMap := make(map[string]string)
	charIndex := 0

	for pageIndex, inputFile := range files {
		fmt.Printf("Processing page %d: %s\n", pageIndex+1, inputFile)

		img, err := loadImage(inputFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error loading image %s: %v\n", inputFile, err)
			os.Exit(1)
		}

		fmt.Printf("  Image size: %dx%d pixels\n", img.Bounds().Dx(), img.Bounds().Dy())
		fmt.Printf("  Cell size: %dx%d pixels\n", config.CellWidthPx(), config.CellHeightPx())

		// Extract cells
		for row := 0; row < config.Rows; row++ {
			for col := 0; col < config.Columns; col++ {
				if charIndex >= len(Charset) {
					fmt.Printf("  Warning: More cells than characters in charset\n")
					break
				}

				char := Charset[charIndex]
				charIndex++

				// Extract cell
				cell := config.ExtractCell(img, row, col)

				// Trim whitespace
				trimmed, _ := TrimWhitespace(cell, uint8(threshold))

				// Make transparent if requested
				var finalImg image.Image
				if transparent {
					finalImg = MakeTransparent(trimmed, uint8(threshold))
				} else {
					finalImg = trimmed
				}

				// Generate filename
				filename := CharToFilename(char) + ".png"
				filepath := filepath.Join(glyphsDir, filename)

				// Save image
				if err := savePNG(finalImg, filepath); err != nil {
					fmt.Fprintf(os.Stderr, "Error saving %s: %v\n", filepath, err)
					continue
				}

				// Add to map
				glyphsMap[string(char)] = filename

				fmt.Printf("  [%d,%d] '%c' -> %s\n", row, col, char, filename)
			}
		}
	}

	// Generate glyphs.json
	glyphsJSON := GlyphsJSON{
		Version: 1,
		CellSize: CellSize{
			Width:  config.CellWidthMM,
			Height: config.CellHeightMM,
		},
		Glyphs: glyphsMap,
	}

	jsonPath := filepath.Join(outputDir, "glyphs.json")
	jsonData, err := json.MarshalIndent(glyphsJSON, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating JSON: %v\n", err)
		os.Exit(1)
	}

	if err := os.WriteFile(jsonPath, jsonData, 0644); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing JSON: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("\nDone! Extracted %d glyphs to %s\n", len(glyphsMap), outputDir)
	fmt.Printf("JSON manifest: %s\n", jsonPath)
}

// loadImage loads an image from file (supports PNG and JPEG)
func loadImage(path string) (image.Image, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(path))
	switch ext {
	case ".png":
		return png.Decode(file)
	case ".jpg", ".jpeg":
		return jpeg.Decode(file)
	default:
		// Try to decode as any format
		img, _, err := image.Decode(file)
		return img, err
	}
}

// savePNG saves an image as PNG
func savePNG(img image.Image, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	return png.Encode(file, img)
}

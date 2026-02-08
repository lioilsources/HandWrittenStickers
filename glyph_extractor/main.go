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

	"golang.org/x/text/unicode/norm"
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

	// Check for rename command
	if len(os.Args) > 1 && os.Args[1] == "rename" {
		if len(os.Args) < 3 {
			fmt.Println("Usage: glyph_extractor rename <glyphs_dir>")
			os.Exit(1)
		}
		if err := renameGlyphs(os.Args[2]); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
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

// renameGlyphs renames glyph files to ASCII-safe names and regenerates glyphs.json
func renameGlyphs(glyphsDir string) error {
	// Read existing files
	entries, err := os.ReadDir(glyphsDir)
	if err != nil {
		return fmt.Errorf("reading directory: %w", err)
	}

	// Build mapping from normalized char to old filename
	oldFiles := make(map[string]string) // normalized char -> old filename
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".png") {
			continue
		}
		oldName := entry.Name()
		charPart := strings.TrimSuffix(oldName, ".png")

		// Handle special filenames that are already converted
		char := filenameToChar(charPart)
		normalized := norm.NFC.String(char)
		oldFiles[normalized] = oldName

		// Also store NFD form for macOS compatibility
		nfd := norm.NFD.String(char)
		if nfd != normalized {
			oldFiles[nfd] = oldName
		}
	}

	fmt.Printf("Found %d PNG files\n", len(oldFiles))

	// Process each character in Charset
	glyphsMap := make(map[string]string)
	renamed := 0
	missing := 0

	for _, r := range Charset {
		char := string(r)
		normalized := norm.NFC.String(char)
		newFilename := CharToFilename(r) + ".png"

		oldFilename, exists := oldFiles[normalized]
		if !exists {
			// Try NFD form (macOS style)
			nfdChar := norm.NFD.String(char)
			oldFilename, exists = oldFiles[nfdChar]
		}

		if !exists {
			fmt.Printf("  MISSING: '%s' (U+%04X)\n", char, r)
			missing++
			continue
		}

		// Add to glyphs map
		glyphsMap[char] = newFilename

		// Rename if needed
		if oldFilename != newFilename {
			oldPath := filepath.Join(glyphsDir, oldFilename)
			newPath := filepath.Join(glyphsDir, newFilename)

			// Check if target already exists (and is different file)
			if _, err := os.Stat(newPath); err == nil && oldPath != newPath {
				fmt.Printf("  CONFLICT: %s already exists, skipping %s\n", newFilename, oldFilename)
				continue
			}

			if err := os.Rename(oldPath, newPath); err != nil {
				fmt.Printf("  ERROR renaming %s -> %s: %v\n", oldFilename, newFilename, err)
				continue
			}
			fmt.Printf("  RENAMED: %s -> %s\n", oldFilename, newFilename)
			renamed++
		}
	}

	fmt.Printf("\nRenamed %d files, %d missing\n", renamed, missing)

	// Generate glyphs.json
	output := GlyphsJSON{
		Version: 1,
		CellSize: CellSize{
			Width:  22.5,
			Height: 26.2,
		},
		Glyphs: glyphsMap,
	}

	jsonData, err := json.MarshalIndent(output, "", "  ")
	if err != nil {
		return fmt.Errorf("creating JSON: %w", err)
	}

	jsonPath := filepath.Join(glyphsDir, "glyphs.json")
	if err := os.WriteFile(jsonPath, jsonData, 0644); err != nil {
		return fmt.Errorf("writing JSON: %w", err)
	}

	fmt.Printf("Written %s with %d glyphs\n", jsonPath, len(glyphsMap))

	// Clean up old files that are no longer needed
	fmt.Println("\nCleaning up unused files...")
	entries, _ = os.ReadDir(glyphsDir)
	validFiles := make(map[string]bool)
	validFiles["glyphs.json"] = true
	for _, filename := range glyphsMap {
		validFiles[filename] = true
	}

	cleaned := 0
	for _, entry := range entries {
		if !validFiles[entry.Name()] && strings.HasSuffix(entry.Name(), ".png") {
			path := filepath.Join(glyphsDir, entry.Name())
			fmt.Printf("  REMOVING unused: %s\n", entry.Name())
			os.Remove(path)
			cleaned++
		}
	}
	fmt.Printf("Cleaned up %d unused files\n", cleaned)

	return nil
}

// filenameToChar converts a filename back to character
func filenameToChar(name string) string {
	switch name {
	case "dot":
		return "."
	case "comma":
		return ","
	case "exclaim":
		return "!"
	case "question":
		return "?"
	case "colon":
		return ":"
	case "semicolon":
		return ";"
	case "hyphen":
		return "-"
	case "underscore":
		return "_"
	case "apostrophe":
		return "'"
	case "doublequote":
		return "\""
	case "slash":
		return "/"
	case "backslash":
		return "\\"
	case "at":
		return "@"
	case "hash":
		return "#"
	case "ampersand":
		return "&"
	case "plus":
		return "+"
	case "equals":
		return "="
	case "percent":
		return "%"
	case "asterisk":
		return "*"
	case "dollar":
		return "$"
	case "space":
		return " "
	case "lparen":
		return "("
	case "rparen":
		return ")"
	case "lbracket":
		return "["
	case "rbracket":
		return "]"
	case "lbrace":
		return "{"
	case "rbrace":
		return "}"
	case "less":
		return "<"
	case "greater":
		return ">"
	case "tilde":
		return "~"
	case "backtick":
		return "`"
	case "caret":
		return "^"
	case "pipe":
		return "|"
	default:
		return name
	}
}

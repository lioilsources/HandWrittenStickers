package main

import (
	"encoding/json"
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
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}
	var err error
	switch os.Args[1] {
	case "template":
		err = runTemplate(os.Args[2:])
	case "reprocess":
		// Applies transparency to existing glyph PNGs
		if len(os.Args) < 3 {
			fmt.Println("Usage: glyph_extractor reprocess <glyphs_dir> [threshold]")
			os.Exit(1)
		}
		thresh := 200
		if len(os.Args) > 3 {
			fmt.Sscanf(os.Args[3], "%d", &thresh)
		}
		err = reprocessGlyphs(os.Args[2], uint8(thresh))
	case "fontset":
		err = runFontSet(os.Args[2:])
	case "rename":
		if len(os.Args) < 3 {
			fmt.Println("Usage: glyph_extractor rename <glyphs_dir>")
			os.Exit(1)
		}
		err = renameGlyphs(os.Args[2])
	case "upgrade":
		err = runUpgrade(os.Args[2:])
	case "segment":
		err = runSegment(os.Args[2:])
	case "assemble":
		err = runAssemble(os.Args[2:])
	case "preview":
		err = runPreview(os.Args[2:])
	case "extract":
		err = runExtract(os.Args[2:])
	case "-h", "-help", "--help", "help":
		printUsage()
		return
	default:
		// Historical form: glyph_extractor --input page1.png,page2.png …
		err = runExtract(os.Args[1:])
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println(`Usage:
  glyph_extractor template [out.pdf]                     Template PDF to fill in by hand
  glyph_extractor template -guide F.ttf -out p1.png,p2.png [-mask grid_mask.png]
                                                         Guide sheets for img2img material letters
  glyph_extractor template -pangram out.pdf              Lined sheet with grey text to trace (free-form handwriting)
  glyph_extractor [extract] -input p1.png,p2.png -output DIR [-bg-mode lightness|chroma|alpha] [-cap-ratio 0.7]
                                                         Extract a template scan into a v2 sheet with metrics
  glyph_extractor upgrade <v1_sheet_dir> [-output DIR]   Trim a v1 cell sheet and add metrics
  glyph_extractor segment -input page.png -output DIR [-labels "line 1\nline 2"]
                                                         Cut free-form writing into candidates.json
  glyph_extractor assemble DIR/candidates.json [-labels labels.json] -output SHEET
                                                         Build a v3 sheet (variants) from labelled candidates
  glyph_extractor preview <sheet_dir> [-out preview.png]  Contact sheet + sample text rendered with metrics
  glyph_extractor fontset -font F.ttf -output DIR -id ID -name NAME
  glyph_extractor fontset -font F.ttf -check
  glyph_extractor reprocess <glyphs_dir> [threshold]
  glyph_extractor rename <glyphs_dir>

Run a command with -h for its flags.`)
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

// reprocessGlyphs applies MakeTransparent to all existing PNG files in a directory
func reprocessGlyphs(dir string, threshold uint8) error {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return fmt.Errorf("reading directory: %w", err)
	}

	processed := 0
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".png") {
			continue
		}

		path := filepath.Join(dir, entry.Name())
		img, err := loadImage(path)
		if err != nil {
			fmt.Printf("  SKIP %s: %v\n", entry.Name(), err)
			continue
		}

		result := MakeTransparent(img, threshold)
		if err := savePNG(result, path); err != nil {
			fmt.Printf("  ERROR %s: %v\n", entry.Name(), err)
			continue
		}

		processed++
		fmt.Printf("  OK %s\n", entry.Name())
	}

	fmt.Printf("\nReprocessed %d glyphs with threshold %d\n", processed, threshold)
	return nil
}

package main

// Charset defines the fixed order of characters in the grid
// Page 1: 80 characters (uppercase + numbers + punctuation)
// Page 2: 80 characters (lowercase + extra symbols)
var Charset = []rune{
	// Page 1 (80 characters)
	// Row 1: Uppercase A-E with diacritics
	'A', 'Á', 'B', 'C', 'Č', 'D', 'Ď', 'E',
	// Row 2: Uppercase E-J with diacritics
	'É', 'Ě', 'F', 'G', 'H', 'I', 'Í', 'J',
	// Row 3: Uppercase K-P with diacritics
	'K', 'L', 'M', 'N', 'Ň', 'O', 'Ó', 'P',
	// Row 4: Uppercase Q-U with diacritics
	'Q', 'R', 'Ř', 'S', 'Š', 'T', 'Ť', 'U',
	// Row 5: Uppercase U-Z with diacritics
	'Ú', 'Ů', 'V', 'W', 'X', 'Y', 'Ý', 'Z',
	// Row 6: Ž + digits 0-6
	'Ž', '0', '1', '2', '3', '4', '5', '6',
	// Row 7: digits 7-9 + basic punctuation
	'7', '8', '9', '.', ',', '!', '?', ':',
	// Row 8: more punctuation
	';', '-', '(', ')', '"', '\'', '/', '@',
	// Row 9: symbols
	'#', '&', '+', '=', '%', '*', '€', '$',
	// Row 10: brackets and special
	'[', ']', '{', '}', '<', '>', '\\', '_',

	// Page 2 (80 characters)
	// Row 1: Lowercase a-e with diacritics
	'a', 'á', 'b', 'c', 'č', 'd', 'ď', 'e',
	// Row 2: Lowercase e-j with diacritics
	'é', 'ě', 'f', 'g', 'h', 'i', 'í', 'j',
	// Row 3: Lowercase k-p with diacritics
	'k', 'l', 'm', 'n', 'ň', 'o', 'ó', 'p',
	// Row 4: Lowercase q-u with diacritics
	'q', 'r', 'ř', 's', 'š', 't', 'ť', 'u',
	// Row 5: Lowercase u-z with diacritics
	'ú', 'ů', 'v', 'w', 'x', 'y', 'ý', 'z',
	// Row 6: ž + misc symbols
	'ž', '~', '`', '^', '|', '©', '®', '™',
	// Row 7: typographic symbols
	'°', '§', '¶', '•', '…', '–', '—', '„',
	// Row 8: quotes and math
	'"', '‚', '\u2019', '«', '»', '×', '÷', '±',
	// Row 9: fractions and superscripts
	'¼', '½', '¾', '¹', '²', '³', 'µ', '¿',
	// Row 10: inverted and foreign
	'¡', 'ñ', 'Ñ', 'ß', 'æ', 'Æ', 'ø', 'Ø',
}

// CharToFilename converts a character to a safe filename
// Some characters cannot be used directly in filenames
func CharToFilename(r rune) string {
	switch r {
	case '/':
		return "slash"
	case '\\':
		return "backslash"
	case ':':
		return "colon"
	case '*':
		return "asterisk"
	case '?':
		return "question"
	case '"':
		return "doublequote"
	case '<':
		return "less"
	case '>':
		return "greater"
	case '|':
		return "pipe"
	case '.':
		return "dot"
	case ',':
		return "comma"
	case '\'':
		return "apostrophe"
	case ' ':
		return "space"
	default:
		return string(r)
	}
}

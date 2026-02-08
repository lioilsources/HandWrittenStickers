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
	'\u201D', '‚', '\u2019', '«', '»', '×', '÷', '±', // " ‚ ' « » × ÷ ±
	// Row 9: fractions and superscripts
	'¼', '½', '¾', '¹', '²', '³', 'µ', '¿',
	// Row 10: inverted and foreign
	'¡', 'ñ', 'Ñ', 'ß', 'æ', 'Æ', 'ø', 'Ø',
}

// CharToFilename converts a character to a safe ASCII filename
// All non-alphanumeric characters are mapped to descriptive names
func CharToFilename(r rune) string {
	switch r {
	// Basic punctuation
	case '.':
		return "dot"
	case ',':
		return "comma"
	case '!':
		return "exclaim"
	case '?':
		return "question"
	case ':':
		return "colon"
	case ';':
		return "semicolon"
	case '-':
		return "hyphen"
	case '_':
		return "underscore"
	case '\'':
		return "apostrophe"
	case '"':
		return "doublequote"
	case '/':
		return "slash"
	case '\\':
		return "backslash"
	case '@':
		return "at"
	case '#':
		return "hash"
	case '&':
		return "ampersand"
	case '+':
		return "plus"
	case '=':
		return "equals"
	case '%':
		return "percent"
	case '*':
		return "asterisk"
	case '$':
		return "dollar"
	case ' ':
		return "space"

	// Brackets
	case '(':
		return "lparen"
	case ')':
		return "rparen"
	case '[':
		return "lbracket"
	case ']':
		return "rbracket"
	case '{':
		return "lbrace"
	case '}':
		return "rbrace"
	case '<':
		return "less"
	case '>':
		return "greater"

	// Special ASCII
	case '~':
		return "tilde"
	case '`':
		return "backtick"
	case '^':
		return "caret"
	case '|':
		return "pipe"

	// Czech uppercase with diacritics
	case 'Á':
		return "A_acute"
	case 'Č':
		return "C_caron"
	case 'Ď':
		return "D_caron"
	case 'É':
		return "E_acute"
	case 'Ě':
		return "E_caron"
	case 'Í':
		return "I_acute"
	case 'Ň':
		return "N_caron"
	case 'Ó':
		return "O_acute"
	case 'Ř':
		return "R_caron"
	case 'Š':
		return "S_caron"
	case 'Ť':
		return "T_caron"
	case 'Ú':
		return "U_acute"
	case 'Ů':
		return "U_ring"
	case 'Ý':
		return "Y_acute"
	case 'Ž':
		return "Z_caron"

	// Czech lowercase with diacritics
	case 'á':
		return "a_acute"
	case 'č':
		return "c_caron"
	case 'ď':
		return "d_caron"
	case 'é':
		return "e_acute"
	case 'ě':
		return "e_caron"
	case 'í':
		return "i_acute"
	case 'ň':
		return "n_caron"
	case 'ó':
		return "o_acute"
	case 'ř':
		return "r_caron"
	case 'š':
		return "s_caron"
	case 'ť':
		return "t_caron"
	case 'ú':
		return "u_acute"
	case 'ů':
		return "u_ring"
	case 'ý':
		return "y_acute"
	case 'ž':
		return "z_caron"

	// Currency and symbols
	case '€':
		return "euro"
	case '©':
		return "copyright"
	case '®':
		return "registered"
	case '™':
		return "trademark"
	case '°':
		return "degree"
	case '§':
		return "section"
	case '¶':
		return "pilcrow"
	case '•':
		return "bullet"
	case '…':
		return "ellipsis"

	// Dashes and quotes
	case '–':
		return "endash"
	case '—':
		return "emdash"
	case '„':
		return "quotelowdbl"
	case '\u201D': // "
		return "quoterightdbl"
	case '‚':
		return "quotelowsgl"
	case '\u2019': // '
		return "quoteright"
	case '«':
		return "guillemotleft"
	case '»':
		return "guillemotright"

	// Math symbols
	case '×':
		return "multiply"
	case '÷':
		return "divide"
	case '±':
		return "plusminus"

	// Fractions and superscripts
	case '¼':
		return "onequarter"
	case '½':
		return "onehalf"
	case '¾':
		return "threequarters"
	case '¹':
		return "onesuperior"
	case '²':
		return "twosuperior"
	case '³':
		return "threesuperior"
	case 'µ':
		return "micro"
	case '¿':
		return "questiondown"
	case '¡':
		return "exclamdown"

	// Foreign characters
	case 'ñ':
		return "n_tilde"
	case 'Ñ':
		return "N_tilde"
	case 'ß':
		return "eszett"
	case 'æ':
		return "ae"
	case 'Æ':
		return "AE"
	case 'ø':
		return "o_stroke"
	case 'Ø':
		return "O_stroke"

	// Default: return as-is (for A-Z, a-z, 0-9)
	default:
		return string(r)
	}
}

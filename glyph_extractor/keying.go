package main

import (
	"fmt"
	"image"
	"image/color"
	"math"
	"sort"
	"strconv"
	"strings"
)

// BgMode selects how the background of a cell is turned transparent.
type BgMode string

const (
	// BgLightness keys by brightness: dark ink on white paper (MakeTransparent).
	BgLightness BgMode = "lightness"
	// BgChroma keys by colour distance (CIE Lab ΔE) from a reference
	// background colour – for coloured material letters and photos.
	BgChroma BgMode = "chroma"
	// BgAlpha keeps the alpha already present in the input PNG (background
	// removed upstream, e.g. by BiRefNet/RMBG in ComfyUI).
	BgAlpha BgMode = "alpha"
)

func ParseBgMode(s string) (BgMode, error) {
	switch BgMode(s) {
	case BgLightness, BgChroma, BgAlpha:
		return BgMode(s), nil
	}
	return "", fmt.Errorf("unknown -bg-mode %q (lightness|chroma|alpha)", s)
}

// KeyOptions configures background removal.
type KeyOptions struct {
	Mode BgMode
	// Threshold is the lightness threshold for BgLightness (0-255).
	Threshold uint8
	// BgColor is the reference background for BgChroma; nil samples it from
	// the corners of every cell.
	BgColor *color.NRGBA
	// Tolerance is the ΔE below which a pixel is background (BgChroma). The
	// alpha ramps up linearly to 255 at 2×Tolerance.
	Tolerance float64
}

// DefaultKeyOptions matches the historical lightness keying.
func DefaultKeyOptions() KeyOptions {
	return KeyOptions{Mode: BgLightness, Threshold: 160, Tolerance: 12}
}

// Key returns a copy of img with a transparent background.
func Key(img image.Image, opts KeyOptions) *image.NRGBA {
	switch opts.Mode {
	case BgChroma:
		bg := opts.BgColor
		if bg == nil {
			c := SampleBackground(img)
			bg = &c
		}
		return MakeTransparentChroma(img, *bg, opts.Tolerance)
	case BgAlpha:
		return toNRGBA(img)
	default:
		return MakeTransparent(img, opts.Threshold).(*image.NRGBA)
	}
}

// TrimAlphaThreshold is the minimum alpha that counts as ink when trimming.
// Lightness keying keeps the historical behaviour (only fully opaque ink),
// chroma and alpha keying have softer mattes.
func (o KeyOptions) TrimAlphaThreshold() uint8 {
	if o.Mode == BgLightness {
		return 255
	}
	return 128
}

// MakeTransparentChroma keys out pixels close to bg in CIE Lab space.
// ΔE < tol → transparent, ΔE > 2·tol → opaque, linear in between. The
// original colours are kept so shading and highlights of material letters
// survive.
func MakeTransparentChroma(img image.Image, bg color.NRGBA, tol float64) *image.NRGBA {
	if tol <= 0 {
		tol = 12
	}
	b := img.Bounds()
	out := image.NewNRGBA(b)
	bgL, bgA, bgB := rgbToLab(bg.R, bg.G, bg.B)
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			c := color.NRGBAModel.Convert(img.At(x, y)).(color.NRGBA)
			l, a, bb := rgbToLab(c.R, c.G, c.B)
			d := math.Sqrt((l-bgL)*(l-bgL) + (a-bgA)*(a-bgA) + (bb-bgB)*(bb-bgB))
			var alpha float64
			switch {
			case d <= tol:
				alpha = 0
			case d >= 2*tol:
				alpha = 1
			default:
				alpha = (d - tol) / tol
			}
			alpha *= float64(c.A) / 255
			if alpha == 0 {
				continue
			}
			out.SetNRGBA(x, y, color.NRGBA{c.R, c.G, c.B, uint8(alpha*255 + 0.5)})
		}
	}
	return out
}

// SampleBackground estimates the background colour of a cell as the
// per-channel median of four corner patches (each 1/10 of the cell size).
func SampleBackground(img image.Image) color.NRGBA {
	b := img.Bounds()
	pw := max(2, b.Dx()/10)
	ph := max(2, b.Dy()/10)
	corners := []image.Point{
		{b.Min.X, b.Min.Y}, {b.Max.X - pw, b.Min.Y},
		{b.Min.X, b.Max.Y - ph}, {b.Max.X - pw, b.Max.Y - ph},
	}
	var rs, gs, bs []int
	for _, p := range corners {
		for y := p.Y; y < p.Y+ph; y++ {
			for x := p.X; x < p.X+pw; x++ {
				c := color.NRGBAModel.Convert(img.At(x, y)).(color.NRGBA)
				rs = append(rs, int(c.R))
				gs = append(gs, int(c.G))
				bs = append(bs, int(c.B))
			}
		}
	}
	return color.NRGBA{uint8(median(rs)), uint8(median(gs)), uint8(median(bs)), 255}
}

// ParseHexColor parses "#rrggbb" or "rrggbb".
func ParseHexColor(s string) (color.NRGBA, error) {
	s = strings.TrimPrefix(strings.TrimSpace(s), "#")
	if len(s) != 6 {
		return color.NRGBA{}, fmt.Errorf("colour %q is not #rrggbb", s)
	}
	v, err := strconv.ParseUint(s, 16, 32)
	if err != nil {
		return color.NRGBA{}, err
	}
	return color.NRGBA{uint8(v >> 16), uint8(v >> 8), uint8(v), 255}, nil
}

func median(v []int) int {
	if len(v) == 0 {
		return 0
	}
	sort.Ints(v)
	return v[len(v)/2]
}

func toNRGBA(img image.Image) *image.NRGBA {
	if n, ok := img.(*image.NRGBA); ok {
		return n
	}
	b := img.Bounds()
	out := image.NewNRGBA(b)
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			out.Set(x, y, img.At(x, y))
		}
	}
	return out
}

// rgbToLab converts sRGB (D65) to CIE L*a*b*.
func rgbToLab(r8, g8, b8 uint8) (float64, float64, float64) {
	lin := func(c uint8) float64 {
		v := float64(c) / 255
		if v <= 0.04045 {
			return v / 12.92
		}
		return math.Pow((v+0.055)/1.055, 2.4)
	}
	r, g, b := lin(r8), lin(g8), lin(b8)
	x := (0.4124*r + 0.3576*g + 0.1805*b) / 0.95047
	y := 0.2126*r + 0.7152*g + 0.0722*b
	z := (0.0193*r + 0.1192*g + 0.9505*b) / 1.08883
	f := func(t float64) float64 {
		if t > 216.0/24389 {
			return math.Cbrt(t)
		}
		return (24389.0/27*t + 16) / 116
	}
	fx, fy, fz := f(x), f(y), f(z)
	return 116*fy - 16, 500 * (fx - fy), 200 * (fy - fz)
}

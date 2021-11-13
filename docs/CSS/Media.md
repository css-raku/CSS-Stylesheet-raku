[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet Module]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::Media](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Media)

class CSS::Media
----------------

CSS Media representation

Synopsis
--------

    use CSS::Units :dpi, :mm;
    use CSS::Stylesheet::Media;
    my CSS::Stylesheet::Media $media .= new: :type<print>, :resolution(300dpi), :width(210mm), :height(297mm), :color(32);
    say $media.orientation;  # portrait
    say $media.aspect-ratio; # 0.707071
    say $media.have('max-height', 250mm); # False
    say $media.have('max-height', 300mm); # True

Description
-----------

Represents a target media for `@media` at-rules.

Attributes
----------

### method type

    use CSS::Stylesheet::Media :MediaType;
    method type() returns MediaType

The basic media type. One of: `braille`, `embossed`, `handheld`, `print`, `projection`, `screen`, `speech`, `tty`, `tv`, `all`

### method resolution

    use CSS::Stylesheet::Media :MediaRes;
    method resolution() returns MediaRes;

The media resolution, given in units of `dpi`, `dpcm`, or `dppx`. Default is `96dpi`.

Example:

    use CSS::Units :dpi, :mm;
    use CSS::Stylesheet::Media;
    my CSS::Stylesheet::Media $media .= new: :type<print>, :resolution(300dpi), :width(210mm), :height(297mm);
    say $media.resolution.gist;  # 300dpi
    say $media.resolution.units; # dpi
    say $media.resolution.scale('dpcm').Int; # 118

### methods width, height

    use CSS::Stylesheet::Media :MediaLen;
    method width() returns MediaLen;
    method height() returns MediaLen;

The width and height of the media in appropriate length units (e.g. `px`, `pt`, `mm`, or `in`).

### methods device-width, device-height

    use CSS::Stylesheet::Media :MediaLen;
    method device-width() returns MediaLen;
    method device-height() returns MediaLen;

The physical width and height of the the display device, often given in `px` units.

### method color

    method color() returns UInt

The color-depth in bits (bits per component). Default 8;

### method color-index

    method color-index() returns UInt

The number of colors (e.g. gray-scale is 1, rgb is 3, cmyk is 4).

Methods
-------

### method orientation

    use CSS::Stylesheet::Media :MediaOrientation;
    method orientation() returns MediaOrientation;

The derived orientation. Assumed to be `portrait` if the `height` is greater than the `width`; `landscape` otherwise.

### method aspect-ratio

    method aspect-ratio() returns Numeric

Computed aspect ratio. Simply `width` / `height`.

### method device-aspect-ratio

    method device-aspect-ratio() returns Numeric

Computed device aspect ratio. Simply `device-width` / `device-height`.

### method have

    use CSS::Stylesheet::Media :MediaProp;
    method have(MediaProp $prop, Numeric $val?) returns Bool

Returns True if the constraint is matched.

For example: `$media.have('min-resolution', 200dpi)` will be `True` for a media with resolution `240dpi`).

The available constraints are: `color`, `min-color`, `max-color`, `color-index`, `min-color-index`, `max-color-index`, `orientation`, `aspect-ratio`, `min-aspect-ratio`, `max-aspect-ratio`, `device-aspect-ratio`, `min-device-aspect-ratio`, `max-device-aspect-ratio`, `height`, `min-height`, `max-height`, `width`, `min-width`, `max-width`, `device-height`, `min-device-height`, `max-device-height`, `device-width`, `min-device-width`, `max-device-width`, `resolution`, `min-resolution`, `max-resolution`.

### method query

    method query(Str $expr) returns Bool

Parses and evaluates a CSS media query. Returns `True` if the media matches, `False` otherwise. Example:

    if $media.query('screen and (orientation: portrait) and (max-width: 600px)') {
           ... # media matches
    }

Which is equivalent to

    use CSS::Units :px;
    if $media.type eq 'screen' && $media.orientation eq 'portrait' && $media.have('max-width', 600px) {
       ...
    }


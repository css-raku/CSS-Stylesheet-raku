#| CSS Media representation
unit class CSS::Media;
use CSS::Properties :&from-ast;
use CSS::Units :Resolution, :Length, :dpi;
use CSS::Module::CSS3;
use CSS::MediaQuery;

subset MediaLen of Numeric is export(:MediaLen) where {!.so || $_ ~~ Length};
subset MediaRes of Numeric is export(:MediaRes) where {!.so || $_ ~~ Resolution};
subset MediaType of Str    is export(:MediaType) where 'braille'|'embossed'|'handheld'|'print'|'projection'|'screen'|'speech'|'tty'|'tv'|'all';
subset MediaOrientation of Str is export(:MediaOrientation) where 'portrait'|'landscape';

has MediaType $.type is required handles<Str>;
has MediaRes $.resolution = 96dpi;
has MediaLen $.width is required;
has MediaLen $.height is required;
has MediaLen $.device-width;
has MediaLen $.device-height;
has UInt $.color = 8;
has UInt $.color-index = 1;
has $.module = CSS::Module::CSS3.module;
method device-width returns MediaLen { $!device-width // $!width }
method device-height returns MediaLen { $!device-height // $!height }

method orientation returns MediaOrientation {
    $!height > $!width.scale($!height.type) ?? 'portrait' !! 'landscape'
}

method aspect-ratio returns Numeric {
    $!width / $!height.scale($!width.type);
}

method device-aspect-ratio returns Numeric {
    my $dev-width := $.device-width;
    $dev-width / $.device-height.scale($dev-width.type);
}

subset MediaProp of Str is export(:MediaProp) where /^
    ['min-'|'max-']? [ 'color''-index'?
                     | ['device-'?['aspect-ratio'|'height'|'width']]
                     ]
  | 'resolution'
  | 'orientation'
$/;

proto method have(Str $prop, $val?) returns Bool {*}
multi method have('color') { ? $!color }
multi method have('color', UInt $n) { ? $!color == $n }
multi method have('min-color', UInt $n) { ? $!color >= $n }
multi method have('max-color', UInt $n) { ? $!color <= $n }

multi method have('color-index') { ? $!color-index }
multi method have('color-index', UInt $n) { ? $!color-index == $n }
multi method have('min-color-index', UInt $n) { ? $!color-index >= $n }
multi method have('max-color-index', UInt $n) { ? $!color-index <= $n }

multi method have('orientation', MediaOrientation $val) {
    $.orientation eq $val
}

multi method have('max-aspect-ratio', Numeric $val) {
    $.aspect-ratio <= $val;
}
multi method have('min-aspect-ratio', Numeric $val) {
    $.aspect-ratio >= $val;
}
multi method have('aspect-ratio', Numeric $val) {
    $.aspect-ratio =~= $val;
}

multi method have('max-height', MediaLen $val) {
    $!height <= $val.scale($!height);
}
multi method have('min-height', MediaLen $val) {
    $!height >= $val.scale($!height);
}
multi method have('height', MediaLen $val) {
    $!height =~= $val.scale($!height);
}

multi method have('max-width', MediaLen $val) {
    $!width <= $val.scale($!width);
}
multi method have('min-width', MediaLen $val) {
    $!width >= $val.scale($!width);
}
multi method have('width', MediaLen $val) {
    $!width =~= $val.scale($!width);
}

multi method have('max-device-height', MediaLen $val) {
    $!device-height <= $val.scale($!device-height);
}
multi method have('min-device-height', MediaLen $val) {
    $!device-height >= $val.scale($!device-height);
}
multi method have('device-height', MediaLen $val) {
    $!device-height =~= $val.scale($!device-height);
}

multi method have('max-device-width', MediaLen $val) {
    $!device-width <= $val.scale($!device-width);
}
multi method have('min-device-width', MediaLen $val) {
    $!device-width >= $val.scale($!device-width);
}
multi method have('device-width', MediaLen $val) {
    $!device-width =~= $val.scale($!device-width);
}

multi method have('max-device-aspect-ratio', Numeric $val) {
    $.device-aspect-ratio <= $val;
}
multi method have('min-device-aspect-ratio', Numeric $val) {
    $.device-aspect-ratio >= $val;
}
multi method have('device-aspect-ratio', Numeric $val) {
    $.device-aspect-ratio =~= $val;
}

multi method have('max-resolution', MediaRes $val) {
    $!resolution <= $val.scale($!resolution);
}
multi method have('min-resolution', MediaRes $val) {
    $!resolution >= $val.scale($!resolution);
}
multi method have('resolution', MediaRes $val) {
    $!resolution =~= $val.scale($!resolution);
}

multi method have($prop, $v) is default {
    warn "ignoring $prop media property";
    True;
}

multi method query(:property(%)! ( :$ident!, :$expr )) {
    with $expr {
        $.have($ident, from-ast($_));
    }
    else { 
        $.have($ident);
   }
}

multi method query(:media-query(@)! (% ( :keyw($_)! ), $media)) {
    when 'only' { $.query(:$media); }
    when 'not'  { ! $.query(:$media); }
    default { fail "unhandled media selection prefix $_"; }
}

multi method query( :media(%)! ( :$ident! ) ) {
    $ident ~~ $!type | 'all'
}

multi method query( :$keyw!) {
    $keyw ~~ 'and';
}

multi method query(:media-query(@)! ($media, *@expr)) {
     $.query(:$media) && ! @expr.first({ ! $.query(|$_) });
}

multi method query(:@media-list!) {
    @media-list.first({ $.query(|$_) });
}

multi method query(CSS::MediaQuery:D() $query) {
    my $media-list = $query.ast;
    $.query(:$media-list);
}

multi method ACCEPTS(CSS::Media:U: $) { True }
multi method ACCEPTS(CSS::Media:D: CSS::MediaQuery() $media-query) {
    with $media-query {
        $.query($_);
    }
    else {
        True;
    }
}

=begin pod

=head2 Synopsis

    use CSS::Units :dpi, :mm;
    use CSS::Stylesheet::Media;
    my CSS::Stylesheet::Media $media .= new: :type<print>, :resolution(300dpi), :width(210mm), :height(297mm), :color(32);
    say $media.orientation;  # portrait
    say $media.aspect-ratio; # 0.707071
    say $media.have('max-height', 250mm); # False
    say $media.have('max-height', 300mm); # True

=head2 Description

Represents a target media for `@media` at-rules.

=head2 Attributes

=head3 method type

    use CSS::Stylesheet::Media :MediaType;
    method type() returns MediaType

The basic media type. One of: `braille`, `embossed`, `handheld`, `print`, `projection`, `screen`, `speech`, `tty`, `tv`, `all`

=head3 method resolution

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

=head3 methods width, height

    use CSS::Stylesheet::Media :MediaLen;
    method width() returns MediaLen;
    method height() returns MediaLen;

The width and height of the media in appropriate length units (e.g. `px`, `pt`, `mm`, or `in`).

=head3 methods device-width, device-height

    use CSS::Stylesheet::Media :MediaLen;
    method device-width() returns MediaLen;
    method device-height() returns MediaLen;

The physical width and height of the the display device, often given in `px` units.

=head3 method color

    method color() returns UInt

The color-depth in bits (bits per component). Default 8;

=head3 method color-index

    method color-index() returns UInt

The number of colors (e.g. gray-scale is 1, rgb is 3, cmyk is 4).

=head2 Methods

=head3 method orientation

    use CSS::Stylesheet::Media :MediaOrientation;
    method orientation() returns MediaOrientation;

The derived orientation. Assumed to be `portrait` if the `height` is greater than the `width`; `landscape` otherwise.

=head3 method aspect-ratio

    method aspect-ratio() returns Numeric

Computed aspect ratio. Simply `width` / `height`.

=head3 method device-aspect-ratio

    method device-aspect-ratio() returns Numeric

Computed device aspect ratio. Simply `device-width` / `device-height`.

=head3 method have

    use CSS::Stylesheet::Media :MediaProp;
    method has(MediaProp $prop, Numeric $val?) returns Bool

Returns True if the constraint is matched.

For example: `$media.have('min-resolution', 200dpi)` will be `True` for a media with resolution `240dpi`).

The available constraints are: `color`, `min-color`, `max-color`,
`color-index`, `min-color-index`, `max-color-index`,
`orientation`,
`aspect-ratio`, `min-aspect-ratio`, `max-aspect-ratio`,
`device-aspect-ratio`, `min-device-aspect-ratio`, `max-device-aspect-ratio`,
`height`, `min-height`, `max-height`,
`width`, `min-width`, `max-width`,
`device-height`, `min-device-height`, `max-device-height`,
`device-width`, `min-device-width`, `max-device-width`,
`resolution`, `min-resolution`, `max-resolution`.

=head3 method query

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

=end pod

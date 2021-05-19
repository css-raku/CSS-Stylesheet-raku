use v6;
use Test;
use CSS::Stylesheet;
use CSS::Media;
use CSS::Units :px;
plan 4;

my $css = q:to<END>;
  h1 { font-size:2em; }
  h2 { font-size:1.5em; }
  @media screen { h1, h2 { color:blue; } }
  @media print { h1, h2 { color:red; } }
  END

my @lines = $css.lines;

my CSS::Stylesheet $stylesheet-plain .= parse($css);
nok $stylesheet-plain.media.defined, 'no media';
is-deeply $stylesheet-plain.Str.lines.Array, @lines, 'no media selection';

my CSS::Media $media .= new: :type<screen>, :width(480px), :height(640px), :color;
my CSS::Stylesheet $stylesheet-screen .= parse($css, :$media);
is $stylesheet-screen.media.type, 'screen', 'screen media type';
@lines.pop;
is-deeply $stylesheet-screen.Str.lines.Array, @lines, 'screen media selection';

done-testing();

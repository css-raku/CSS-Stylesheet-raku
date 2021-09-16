use Test;
plan 3;

use CSS::Stylesheet;
use CSS::Media;
use CSS::Units :px, :dpi;

my $css = q:to<END>;
  @import "t/css/style2.css";
  h1 {
      color:green;
  }
  END

my CSS::Stylesheet $stylesheet .= new(:import).parse($css);

is-deeply $stylesheet.Str(:!pretty).lines, (
      'h2 { color:blue; }',
      'h1 { color:green; }',
  ), 'single import';

$css = q:to<END>;
  @import "t/css/style1.css" screen;
  @import "t/css/style2.css" print;
  h1 {
      color:green;
  }
  END

$stylesheet .= new(:import).parse($css);
is-deeply $stylesheet.Str.lines, (
      '@media screen { h2 { color:green; } }',
      '@media print { h2 { color:blue; } }',
      'h1 { color:green; }',
  ), 'uinfiltered import';

my CSS::Media $media .= new: :type<screen>, :width(640px), :height(480px);
$stylesheet .= new(:import, :$media).parse($css);
is-deeply $stylesheet.Str.lines, (
      '@media screen { h2 { color:green; } }',
      'h1 { color:green; }',
  ), 'media-filtered import';

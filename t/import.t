use Test;
plan 1;

use CSS::Stylesheet;
my $css = q:to<END>;
  @import "t/css/style2.css";
   
  h1 {
      color:green;   
  }
  END

my CSS::Stylesheet $stylesheet .= new(:import).parse($css);

is-deeply $stylesheet.Str(:!pretty).lines, (
      'body { background:black; opacity:0.5; }',
      'h1 { color:green; }',
  );

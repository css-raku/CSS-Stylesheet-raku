use v6;
use Test;
use CSS::Stylesheet;
plan 8;

my $css = q:to<END>;
@page { margin:2cm; size:a4; @top-center { content:'Page ' counter(page); } }
@page :left { margin-left:4cm; }
@page :right { margin-right:4cm; }
h1 { color:blue; }
END

my @lines = $css.lines;

my CSS::Stylesheet $stylesheet .= new.parse($css);
is $stylesheet.rules[0].xpath, '//h1';
is $stylesheet.at-pages[0].Str, @lines[0];
is $stylesheet.at-pages[1].Str, @lines[1];
is $stylesheet.page-properties, "margin:2cm; size:a4;";
is $stylesheet.page-properties(:right), "margin:2cm 4cm 2cm 2cm; size:a4;";
is $stylesheet.page-properties(:margin-box<top-center>).Str, "content:'Page ' counter(page);";
is $stylesheet.page-properties(:margin-box<top-right>).Str, "display:none;";
is-deeply $stylesheet.Str.lines, @lines.List, 'Str method';

done-testing;

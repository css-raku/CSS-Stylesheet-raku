use v6;
use Test;
use CSS::Stylesheet;
plan 6;

my $css = q:to<END>;
@page { margin: 2cm; size: a4; @top-center { content: 'Page ' counter(page); }}
@page :left  { margin-left:  4cm; }
@page :right { margin-right: 4cm; }
h1 { color: blue; }
END

my CSS::Stylesheet $stylesheet .= new.parse($css);
is $stylesheet.rules[0].xpath, '//h1';
todo "page boxes";
isnt $stylesheet.at-pages[0].Str, '@page { margin:2cm; size:a4; }';
is $stylesheet.at-pages[1].Str, '@page :left { margin-left:4cm; }';
is $stylesheet.page, "margin:2cm; size:a4;";
is $stylesheet.page(:right), "margin:2cm 4cm 2cm 2cm; size:a4;";
is $stylesheet.page(:margin-box<top-center>).Str, "content:'Page ' counter(page);";

done-testing;

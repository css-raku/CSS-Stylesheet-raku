use v6;
use Test;
use CSS::Stylesheet;
plan 3;

my $css = q:to<END>;
@page { margin: 2cm; @top-center { content: 'Page ' counter(page); }}
@page :left  { margin-left:  4cm; size: a4 }
@page :right { margin-right: 4cm; size: a4 }
h1 { color: blue; }
END

my CSS::Stylesheet $stylesheet .= new.parse($css);
is $stylesheet.rules[0].xpath, '//h1';
todo "page boxes";
isnt $stylesheet.page[0].Str, '@page { margin:2cm; }';
is $stylesheet.page[1].Str, '@page :left { margin-left:4cm; size:a4; }';

done-testing;

use v6;
use Test;
use CSS::Stylesheet;
plan 6;

my $css = q:to<END>;
p { color:blue; font-family:'Para'; }
@media print { p { font-family:'Print'; } @font-face { font-family:'Print'; src:url('/myfonts/print.otf'); } }
@font-face { font-family:'Para'; src:url('/myfonts/para.otf') format('opentype'); }
END

my @lines = $css.lines;

my CSS::Stylesheet $stylesheet .= new.parse($css);
is $stylesheet.rules[0].xpath, '//p';
is +$stylesheet.font-face, 2, 'font face rules loaded';
isa-ok $stylesheet.font-face[0], 'CSS::Properties';
is $stylesheet.font-face('Para').Str, "font-family:'Para'; src:url('/myfonts/para.otf') format('opentype');";
is $stylesheet.font-face[0].Str, "font-family:'Print'; src:url('/myfonts/print.otf');";
is-deeply $stylesheet.Str.lines, @lines.List, 'Str method';

done-testing;

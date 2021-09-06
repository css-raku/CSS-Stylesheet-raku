use v6;
use Test;
use CSS::Stylesheet;
plan 14;

my $css = q:to<END>;
p { color:blue; font-family:'Para'; }
@media print { p { font-family:'Print'; } @font-face { font-family:'Print'; src:url('myfonts/print.otf'); } }
@font-face { font-family:'Para'; src:url('myfonts/para.otf') format('opentype'); }
END

my @lines = $css.lines;

my CSS::Stylesheet $stylesheet .= new(:base-url<t>).parse($css);
is $stylesheet.rules[0].xpath, '//p';
is +$stylesheet.font-face, 2, 'font face rules loaded';
isa-ok $stylesheet.font-face[0], 'CSS::Font::Descriptor';
is $stylesheet.font-face('Para').Str, "font-family:'Para'; src:url('myfonts/para.otf') format('opentype');";
is $stylesheet.font-face[0].Str, "font-family:'Print'; src:url('myfonts/print.otf');";
is-deeply $stylesheet.Str.lines, @lines.List, 'Str method';

my $font-resources = $stylesheet.font-resources("12pt Para");
isa-ok $font-resources, "CSS::Font::Resources";
isa-ok $font-resources.font, "CSS::Font";
isa-ok $font-resources.font-face[0], "CSS::Font::Descriptor";

my @sources = $font-resources.sources;
is +@sources, 2;
given @sources.head {
    .&isa-ok: 'CSS::Font::Resources::Source::Url';
    .url.Str.&is: 't/myfonts/para.otf';
    .family.&is: 'Para';
    .format.&is: 'opentype';
}

done-testing;

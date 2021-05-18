use Test;
plan 1;
use CSS::Stylesheet;
use CSS::Ruleset;
use CSS::AtPageRule;
use CSS::MediaQuery;

my CSS::MediaQuery() $media-query = 'print';
my CSS::Ruleset $h1 .= new: :selectors<h1>, :properties("color:blue");
my CSS::Ruleset $h1-print .= new: :selectors<h1>, :properties("color:black"), :$media-query;
my CSS::Properties() $page-props = 'margin:4pt'; 
my CSS::AtPageRule $at-page .= new: :properties($page-props);
my CSS::Stylesheet $stylesheet .= new: :rules[$h1, $h1-print], :at-pages[$at-page];

my $expected = q:to<END>;
@page { margin:4pt; }
h1 { color:blue; }
@media print { h1 { color:black; } }
END

is-deeply $stylesheet.Str.lines, $expected.lines;


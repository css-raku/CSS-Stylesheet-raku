#| @media query representation
unit class CSS::MediaQuery;

use CSS::Module;
use CSS::Module::CSS3;

#|AST data repesentation of a query
has @.ast is required;

#| parse a media query
method parse(Str:D $media-query, CSS::Module :$module = CSS::Module::CSS3.module, |c --> CSS::MediaQuery) {
    my $actions = $module.actions.new;
    my $p := $module.parse($media-query, :rule<media-list>, :$actions)
        or die "unable to parse CSS media-list: $media-query";
    my @ast = $p.ast.List;
    self.new: :@ast, |c;
}

multi method COERCE(Str $media-query) { self.parse: $media-query }

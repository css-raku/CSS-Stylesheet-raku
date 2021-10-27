#| Selector component of rule-sets
unit class CSS::Selectors;

use CSS::Selector::To::XPath;
use CSS::Module;
use CSS::Module::CSS3;

has %.ast;
has Version $!specificity;
has CSS::Selector::To::XPath $!to-xml .= new;

submethod TWEAK {
    for <active focus link hover visited> {
        $!to-xml.pseudo-classes{$_} = "link-pseudo('$_', .)";
    }
}

multi method parse(CSS::Selectors:U: Str $selectors!, :$module = CSS::Module::CSS3.module, |c --> CSS::Selectors) {
    my $actions = $module.actions.new;
    my $p := $module.parse($selectors, :rule<selectors>, :$actions)
        or die "unable to parse CSS selectors: $selectors";
    note $_ for $actions.warnings;
    my $ast = $p.ast;
    self.new: :$ast, |c;
}

class Specificity {
    has UInt $!id     = 0;
    has UInt $!class  = 0;
    has UInt $!type   = 0;

    multi method calc(:simple-selector($_)!) {
        $.calc(|$_) for .list;
    }

    multi method calc(:selector($_)!) {
        $.calc(|$_) for .list;
    }

    multi method calc(:selectors($_)!) {
        $.calc(|$_) for .list;
        Version.new: ($!id, $!class, $!type).join: '.';
    }

    multi method calc(:qname($_)!) {
        $!type++ unless .<element-name> ~~ '*';
    }
    multi method calc(:attrib($)!)       { $!class++ }
    multi method calc(:class($)!)        { $!class++ }
    multi method calc(:pseudo-class($)!) { $!class++ }
    multi method calc(:pseudo-elem($)!)  { $!class++ }
    multi method calc(:pseudo-func($_)!) {
        with .<expr> {
            $.calc(|$_) for .list;
        }
    }
    multi method calc(:id($)!)             { $!id++ }
    multi method calc(:op($)!)             {}

    multi method calc(*%frag) is default {
        warn "ignoring {%frag.raku}";
    }

}

=head2 Methods

#| Returns selector specificity in the form v<id>.<class>.<type>
method specificity returns Version {
    $!specificity //= do {
        my Specificity $spec .= new;
        $spec.calc: |%!ast;
    }
}

#| Returns an XPath translation of the selector
method xpath returns Str {
    $!to-xml.xpath: %!ast;
}

multi method COERCE(Str $selectors) { self.parse: $selectors }

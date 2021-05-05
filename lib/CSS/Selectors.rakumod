#| selector component of rule-sets
unit class CSS::Selectors;

use CSS::Selector::To::XPath;

has %.ast is required;
has Version $!specificity;
has CSS::Selector::To::XPath $!to-xml .= new;

submethod TWEAK {
    for <active focus link hover visited> {
        $!to-xml.pseudo-classes{$_} = "link-pseudo('$_', .)";
    }
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
        warn "ignoring {%frag.perl}";
    }

}

=head2 Methods

#| Returns selector specificity in the form v<id>.<class>.<type>
method specificity returns Version {
    $!specificity //= do {
        my Specificity $spec .= new;
        $spec.calc(|%!ast);
    }
}

#| Returns an XPath translation of the selector
method xpath returns Str {
    $!to-xml.xpath(%!ast);
}


unit role CSS::Stylesheet::Actions;

use CSS::URI;
use CSS::Grammar::Actions;

has Bool $.import;
has Str() $.base-url = '.';

method import($/) {
    callsame;
    if $!import {
        my Str:D $url = $/.ast<at-rule><url>;
        my CSS::URI $uri .= new: :$url, :$!base-url;
        $/.ast<at-rule><content> = $uri.get;
    }
    else {
        my Str() $str = $/;
        @.warnings.push: X::CSS::Ignored.new(:$str, :message('ignored'), :explanation('use :import to enable'));
    }
}

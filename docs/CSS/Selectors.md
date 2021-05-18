[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::Selectors](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Selectors)

class CSS::Selectors
--------------------

Selector component of rule-sets

Methods
-------

### method specificity

```raku
method specificity() returns Version
```

Returns selector specificity in the form v<id>.<class>.<type>

### method xpath

```raku
method xpath() returns Str
```

Returns an XPath translation of the selector


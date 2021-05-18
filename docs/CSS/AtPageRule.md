[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::AtPageRule](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/AtPageRule)

class CSS::AtPageRule
---------------------

@page at-rule representation, including margin boxes

### has Str $.pseudo-class

(optional) .e.g. 'left', 'right', 'first'

### has CSS::Properties(Any) $.properties

Top-level CSS properties

### has Associative[CSS::Properties(Any)] %.margin-box

Per page margin CSS properties

### method ast

```raku
method ast(
    |c
) returns Mu
```

return AST representation of a single @page at-rule

### method Str

```raku
method Str(
    :$optimize = Bool::True,
    Bool :$terse = Bool::True,
    *%opt
) returns Mu
```

serialize a @page rule to CSS


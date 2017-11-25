+++
date = "2017-08-11T16:06:56-05:00"
description = "Are named returns ok in Go? Totally!"
draft = true
tags = []
title = "Named Returns for Fun and Profit in Go"
topics = ["bash"]

+++
I remember running across named return values in Go when I first started
learning the language.  It wasn't a language feature that I really payed
attention to at first, because, to be honest, it seems pretty vanilla compared
to the exciting bits in the language (channels, goroutines, first-class
functions, `defer`, etc.).  Moreover, it seemed like the primary use case for
named return values is enabling so-called `naked returns`.  However, [A Tour of
Go](https://tour.golang.org/basics/7) itself warns against the usage of naked
returns for anything but very simple functions:

> Naked return statements should be used only in short functions....
> They can harm readability in longer functions.

In fact, I've seen very few use cases where naked returns do anything but trade
ability to reason about the code for compactness -- a very poor trade in my
opinion.  However, there are several other use cases for which named return
values that are very convenient (and don't sacrifice readability or
maintainability).

### Application Metrics

Coming from a primarily Python background, one of the language features I miss
most in Go is decorators.  Of course, Go has great support for functions as
first-class objects, but the syntax is admittedly much less natural and, more
problematic, modifies the underlying function signatures.  One of my most
common uses decorators in Python was recording latencies and errors in function
calls to be exposed up as application metrics.  Recording latencies is simple
enough in Go, but if you want to include some information about state or errors
encountered in your metrics, things get considerably clunkier.  But no fear...
named returns to the rescue!

```golang
func foo(...) (val interface{}, err error) {

}
```

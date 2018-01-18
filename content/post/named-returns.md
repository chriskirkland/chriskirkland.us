+++
date = "2017-08-11T16:06:56-05:00"
description = "Are named returns ok in Go? Totally!"
draft = true
tags = []
title = "Named Returns for Fun and Profit in Go"
topics = ["bash"]

+++
I remember running across named return values in Go when I first started
learning the language.  It wasn't a language feature that I payed attention to
at first, because, to be honest, it seems pretty vanilla compared to the
exciting bits in the language (channels, goroutines, first-class functions,
`defer`, etc.).  Moreover, it seemed like the primary use case for named return
values is enabling so-called `naked returns`.  However, [A Tour of
Go](https://tour.golang.org/basics/7) itself warns against the usage of naked
returns for anything but very simple functions:

> Naked return statements should be used only in short functions....  They can
> harm readability in longer functions.

In fact, I've seen very few use cases where naked returns do anything but trade
ability to reason about the code for compactness -- a very poor trade in my
opinion.  However, there are several other use cases for which named return
values that are very convenient (and don't sacrifice readability or
maintainability).

### Unexpected Implications

One of the interesting things about `defer`, is that the function definition
(i.e. the function signature and the value of any parameters) is locked in
at defer-time but any of the variables in scope that are _closed over_ have
their values determined when the function is executed, in particular, just
before the function exits.  Here is a simple example to demonstrate the
distinction:

```golang
package main

import "fmt"

func main() {
	closed := 0
	for i := 0; i < 5; i++ {
		func(param int) {
			fmt.Println(param, closed)
		}(i)
		closed++
	}
}

# OUTPUT
4 5
3 5
2 5
1 5
0 5
```

If we combine behavior of `defer` with respect to values that are _closed over_
with named returns, we see that we can actually access the values returned by
the function:

```golang
package main

import "fmt"

func main() {
	fib(7)
}

func fib(n int) (result int) {
	defer func() {
		fmt.Printf("fib(%d) = %d\n", n, result)
	}()

	prev, curr := 0, 1
	for i := 1; i < n; i++ {
		prev, curr = curr, curr+prev
	}
	return curr
}

# OUTPUT
fib(7) = 21
```

Obviously this trivial example is contrived, but it demonstrates the core idea
that we can apply to some real world use cases.

### Application Metrics

Coming from a primarily Python background, one of the language features I miss
most in Go is decorators.  Of course, Go has great support for functions as
first-class objects, but the syntax is admittedly much less natural and, more
problematic, modifies the underlying function signatures.  One of my most common
uses decorators in Python was recording latencies and errors in function calls
to be exposed up as application metrics.  Recording latencies is simple enough
in Go, but if you want to include some information about state or errors
encountered in your metrics, things get considerably clunkier.  But no fear...
named returns to the rescue!

```golang
func foo(...) (val interface{}, err error) {
    defer func(start time.Time) {
        duration := time.Now().Since(start)
        registerMetric("metric-label", duration, err)
    }(time.Now())

  /* actual logic with multiple returns */
}
```

These four lines of boilerplate can be added to any function to hook into some
function to register the desired metric with an error (nil or not) and the
function execution time.  Especially in function with multiple returns (you are
handling your errors right?), this is a convenient way to reduce code
duplication and segregate application logic from instrumentation logic.  For the
_outter_ most functions in a HTTP or gRPC API server, we can use something like
middlewares or interceptors (respectively) to do this for us.  However, for
internal parts of the code that don't have those convenient injection points,
it's nice to have a concise pattern for injective observability data.

### Another Fantastic Example

### Yet Another Fantastic Example

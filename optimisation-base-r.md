---
title: 'Base R optimisations'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why are R loops slower than vectorised functions?
- How can I make my code more readable and faster?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain the importance of getting to underlying C code as soon as possible
- Take advantage of vectorisation in R to write concise and fast code
- Identify the most efficient built-in R solution for a number of common scenarios

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

Much of the core R codebase is written in C and Fortran. As compiled languages, this code is much faster to run. Calling an R function always ends up calling some underlying C or Fortran code. We can inspect the source code for an R function by entering its name in the console, *not* followed by parentheses. The base R function `runif`, for example, only contains a single line, which consists of a call, via `.Call`, to an implementation written in C, `C_runif`:

```r
function (n, min = 0, max = 1) 
.Call(C_runif, n, min, max)
```

A golden rule in R programming is to access underlying C/Fortran routines as quickly as possible, making as few R function calls as possible. Consider a standard numeric vector, `x`, of length `n`. Then 

```r
x <- x + 1
```

involves a single function call to `+`. Consider an alternative implementation:

```r
for (i in seq_along(x)) {
   x[i] <- x[i] + 1
}
```

:::::: discussion

How many function calls are there in the above `for` loop?

::::::

:::::: instructor
- `n` function calls to +;
- `n` function calls to the `[` function;
- `n` function calls to the `[<-` function (used in the assignment operation);
- Two function calls: one to `for` and another to `seq_len()`.
::::::


`for` loops tend to be slow in R, not because `for` itself is slow, but because loops have far more function calls than their vectorised alternatives, each with overhead.

:::::: challenge
Use `bench::mark()` to compare the performance of the vectorised `x <- x + 1` vs. `for` loop version. Try varying the size of the input vector. 

Note that you need to set `check = FALSE` in the call to `bench::mark()` because whichever of the approaches you run first changes the value of `x`, so other has a different starting and, therefore, end values.

::: solution


``` r
vect <- function(x) {x <- x + 1}
loop <- function(x) {
   for (i in seq_along(x)) {
      x[i] <- x[i] + 1
   }   
}

x <- runif(10000)
bench::mark(
   vect(x),
   loop(x),
   check = FALSE # necessary because running vect(x) changes the value of x
)
```

``` output
# A tibble: 2 × 6
  expression      min   median `itr/sec` mem_alloc `gc/sec`
  <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
1 vect(x)      5.37µs   31.1µs    32552.    78.2KB    52.2 
2 loop(x)    471.15µs  511.5µs     1972.   101.5KB     4.11
```

:::
::::::

## Vectorised code

In the above section, `x <- x + 1` is an example of a vectorised operation. *Vectorisation* is operating on vectors (or vector-like objects) as a whole, rather than individual elements. This whole-object approach has a number of benefits:

- It makes problems simpler to think about entire vectors, rather than individual elements
- Loops in vectorised functions are written in C, and are much faster than loops in R because they have less overhead
- Vectorised code is shorter and easier to read

Many functions in R are vectorised, e.g.


``` r
x <- 1:3
y <- 3:1
x == y
```

``` output
[1] FALSE  TRUE FALSE
```

``` r
log(x)
```

``` output
[1] 0.0000000 0.6931472 1.0986123
```

``` r
res <- list(a = 1:3, b = 1:6)
lengths(res)
```

``` output
a b 
3 6 
```


:::::: challenge

Write a function, `variance` to compute the variance of a numeric vector, `x`, of length `n`, making use of R's built in vectorisation.

$$
Var(x) = \frac{1}{n-1}\sum_{i=1}^n(x_i - \bar{x})^2
$$
Microbenchmark your approach compared to the base R `var()` implementation, with `x <- runif(10000)`. Why do you think the built-in version is faster?

::: hint
Look at the source code for `var`.
:::


::: solution

``` r
variance <- function(x) {
  1/(length(x) - 1) * sum((x - mean(x))^2)
}

x <- runif(10000)
bench::mark(
   variance(x),
   var(x)
)
```

``` output
# A tibble: 2 × 6
  expression       min   median `itr/sec` mem_alloc `gc/sec`
  <bch:expr>  <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
1 variance(x)   70.4µs   93.4µs    11432.    78.2KB    17.5 
2 var(x)        61.4µs     65µs    15151.    15.3KB     4.05
```

`var()` performs the variance calculation in C.
:::

::::::

## Vectorisation and matrices

Vectorisation applies to matrices too, both for matrix algebra, and vectorised functions:


``` r
M <- matrix(1:4, nrow = 2)
M + M
```

``` output
     [,1] [,2]
[1,]    2    6
[2,]    4    8
```

``` r
M + 1.3
```

``` output
     [,1] [,2]
[1,]  2.3  4.3
[2,]  3.3  5.3
```

``` r
round(M + 1.3)
```

``` output
     [,1] [,2]
[1,]    2    4
[2,]    3    5
```

There are several functions available for implementing efficient row/column-wise operations on matrices (and numeric data frames), e.g.`colMeans()`, `rowMeans()`, `colSums()`, `rowSums()`. These provide a much faster alternative to iterating over rows or columns. 

## Faster common operations

There are often many different ways to achieve the same result in R. Looking at the help page for a function is a good way to check whether there are any arguments to the function, or any faster implementations for certain cases. Here are some examples of fast ways to solve common problems:

- Sorting
   - Use `sort(x, partial = 1:10)[10]` instead of `sort(x)[1:10]` to get the top 10
   - Use `sort(x, decreasing = TRUE)` instead of `rev(sort(x))`

- Generating numeric vectors
   - `seq.int()`, `seq_along(x)`, `seq_len(n)` instead of `seq()`
   - `rep.int()` or `rep_len(x, length.out)` vs `rep()`

- `which.min()`, `which.max()` instead of e.g. `which(x == min(x))`

- `anyNA(x)` instead of `any(is.na(x))`

::::::::::::::::::::::::::::::::::::: keypoints 

- Avoid extraneous function calls - get to the underlying C code as fast as possible
- Think in terms of whole vectors rather than individual elements, and take advantage of R's built-in vectorisation
- Look at the help pages for base R functions to see if they contain any arguments or alternative versions which might speed-up calculations.

::::::::::::::::::::::::::::::::::::::::::::::::


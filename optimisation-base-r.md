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
- Two function calls: one to `for` and another to `seq_along()`.
::::::


`for` loops tend to be slow in R, not because `for` itself is slow, but because loops have far more function calls than their vectorised alternatives, each with overhead.

:::::: challenge
Use `bench::mark()` to compare the performance of the vectorised `x <- x + 1` vs. `for` loop version. Try varying the size of the input vector. 

Note that you need to set `check = FALSE` in the call to `bench::mark()` because whichever of the approaches you run first changes the value of `x`, so other has a different starting and, therefore, end values.

::: solution


``` r
vect <- function(x) {
   x <- x + 1
   x
}
loop <- function(x) {
   for (i in seq_along(x)) {
      x[i] <- x[i] + 1
   }
   x   
}

x <- runif(10000)
bench::mark(
   vect(x),
   loop(x)
)
```

``` output
# A tibble: 2 × 6
  expression      min   median `itr/sec` mem_alloc `gc/sec`
  <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
1 vect(x)      3.35µs   26.4µs    38571.    78.2KB    61.8 
2 loop(x)    268.91µs  288.4µs     3417.   101.5KB     6.19
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
1 variance(x)   46.7µs   51.2µs    17093.    78.2KB     28.8
2 var(x)        44.7µs   47.1µs    21011.    15.3KB      0  
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
   - Use `sort(x, partial = 1:10)[1:10]` instead of `sort(x)[1:10]` to get the top 10
   - Use `sort(x, decreasing = TRUE)` instead of `rev(sort(x))`

::: instructor
Show the difference between the following:

``` r
x <- sample(50)
x
```

``` output
 [1] 48 40 12 18 46 50  1 33  2 22 35 21 19 30 29 11  8 45 16 34 41 13 24 27 43
[26] 14 17  3 47  7 42 28  4 15  6 44 49 36 37 26 20 38  5 32 39 25 23  9 31 10
```

``` r
sort(x)
```

``` output
 [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
[26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
```

``` r
sort(x, partial=1:10)
```

``` output
 [1]  1  2  3  4  5  6  7  8  9 10 12 11 13 14 19 21 15 17 16 20 18 41 24 27 43
[26] 34 45 29 47 30 42 28 35 22 33 44 49 36 37 26 50 38 46 32 39 25 23 40 31 48
```
:::

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


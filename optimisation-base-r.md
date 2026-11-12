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
1 vect(x)      5.46µs   31.4µs    31768.    78.2KB    50.9 
2 loop(x)     458.4µs  475.9µs     2069.   101.5KB     4.09
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
1 variance(x)   69.9µs   78.8µs    11954.    78.2KB    19.7 
2 var(x)        61.4µs   65.1µs    15131.    15.3KB     2.01
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
 [1] 48 27 29 31 37 35 40  8 28 10 25 15 22 36 18 45 43  5  7 26 33 42 34 39 41
[26] 16 32  1 30  2 44 46  3  4 24 14 49 20 17 13 11  9 38 47 12  6 19 23 50 21
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
 [1]  1  2  3  4  5  6  7  8  9 10 25 15 22 36 18 45 43 28 40 26 33 42 34 39 41
[26] 16 32 35 30 37 44 46 31 29 24 14 49 20 17 13 11 27 38 47 12 48 19 23 50 21
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


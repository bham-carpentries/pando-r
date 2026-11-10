---
title: 'Memory Management'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- ...

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Recognise when R will create a copy of an object
- Explain why pre-allocating memory is more efficient than growing vectors and data frames
- Determine when to cache variables

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

Objects created in R are stored in memory. This has the advantage that objects can be accessed faster, but R slows down as the memory fills up. Creating objects also takes time. Here are some tips to avoid creating objects unnecessarily:

- Re-use temporary variables, e.g. `x <- x + 1` instead of `y <- x + 1`. The allocated storage will be re-used if the vector has the same length.
- Don't save intermediate results unnecessarily - compute on-the-fly
- Use `rm()` to remove large objects when no-longer needed
- Cache variables - calculate objects once a resuse the value when necessary. For example, replace `sd(x)` in multiple function calls with the object `sd_x` that is defined once and reused.


## Data structures

Use the simplest data structure for your purpose, to minisime the amount of memory you need. For example:

- If you have rectangular data of the same type, prefer a matrix to a data frame
- Use character or integer vectors instead of factors
- Use logical or integer vectors instead of numeric vectors
- Use unnamed objects instead of named objects.

It is especially important to use low-level structure for computation. You can create richer objects as a final step before returning them to the user.

## Don't grow objects

In R, growing objects with a loop is notoriously slow. This is because whenever you use `c()`, `append()`, `cbind()`, `rbind()` or `paste()` to create a bigger object, R must first allocate space for the new object and then copy the old object to the new space. Repeating this many times is computationally expensive.

Let's compare three ways of creating a sequence of numbers. We will wrap each of these as a function, to make it easier to benchmark their performance.

Method 1: grow the object


``` r
grow <- function(n) {
   vec <- numeric(0)
   for (i in seq_len(n)) {
      vec <- c(vec, i)
   }
   vec
}
```

Method 2: create an object of the final length then change the values in the object by subsetting:


``` r
pre_allocate <- function(n) {
   vec <- numeric(n)
   for (i in seq_len(n)) {
      vec[i] <- i
   }
   vec
}
```

::: callout
`numeric(n)`, `integer(n)`, `logical(n)`, `character(n)` initialise vectors of length `n` of the type given as the function name. To initialise a list, we can use `vector(mode = "list", length = n)`.
:::

Method 3: create the final object directly 


``` r
direct <- function(n) {
   seq_len(n)
}
```

::: callout
Note that many sequences can be created directly with `seq()` and `rep()`. See their help pages to learn about all their arguments.
:::

:::::: challenge
Which of `grow()`, `pre_allocate()` and `direct()` do you expect to perform best and why? Which of the methods do you think will scale best as `n` increases? Which do you think will scale worst?

Use microbenchmarking to test your intuition. Try different values of `n`. At what size so you start to notice differences? 

::: hint 
In which method do you get to the underlying C code the fastest?
:::

::: solution

``` r
n <- 10000
bench::mark(
   grow(n),
   pre_allocate(n),
   direct(n)
)
```

``` warning
Warning: Some expressions had a GC in every iteration; so filtering is
disabled.
```

``` output
# A tibble: 3 × 6
  expression           min   median  `itr/sec` mem_alloc `gc/sec`
  <bch:expr>      <bch:tm> <bch:tm>      <dbl> <bch:byt>    <dbl>
1 grow(n)           93.6ms   96.8ms       9.99     382MB   104.  
2 pre_allocate(n)    333µs  338.2µs    2859.      98.6KB     6.00
3 direct(n)        311.1ns    491ns 1359988.          0B     0   
```

Note the orders of magnitude difference in the results. `pre_allocate(10000)` is over 300 times faster than `grow(10000)`. Where it is possible to directly specify your vector, that is orders of magnitude faster again. In this case, `direct(10000)` is nearly 1500 times faster than `pre_allocate(10000)`. That's quite the speed-up!

When `n <- 10000000`, method 1 takes about an hour, whereas method 3 is pretty much instantaneous.
:::

::::::


::::::::::::::::::::::::::::::::::::: keypoints 

- Avoid creating objects unnecessarily
- Use the simplest data structure for your needs
- Do not grow objects. Create them directly if you can. Otherwise, pre-allocate the memory prior to running a loop.

::::::::::::::::::::::::::::::::::::::::::::::::


---
title: 'Memory Management'
teaching: 15
exercises: 5
---

:::::::::::::::::::::::::::::::::::::: questions

- How does R store objects in memory?
- When does R copy an object?
- Why is growing an object in a loop so slow?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Recognise when R will create a copy of an object
- Explain why pre-allocating memory is more efficient than growing vectors and data frames
- Determine when to cache variables

::::::::::::::::::::::::::::::::::::::::::::::::

Objects created in R are stored in memory (RAM). This makes them fast to access, but R slows down as the memory fills up, and creating objects also takes time.  There are well-known pitfalls in R when it comes to managing memory. Understanding how R handles memory, and when it makes copies of objects, helps us avoid these.

## How R handles memory

When you run `x <- c(1, 2, 3)`, R does two things. It creates a vector in
memory, and it binds the name `x` to that vector. The name is a *reference*
to the object, not the object itself. So `y <- x` doesn't copy anything:
`x` and `y` both point to the same object.

R makes a copy only when you **modify** an object that has more than one
name. This is called **copy-on-modify**. You can watch it happen with
`tracemem()`, which prints a message every time an object is copied:


``` r
x <- c(1, 2, 3)
tracemem(x)
y <- x          # no copy: two names, one object
y[[3]] <- 4     # copy: changing y must not change x
#> tracemem[0x55d5c8e0b2a8 -> 0x55d5c8e0b6f8]:
y[[2]] <- 10    # no copy: y now has its own object, with one name
untracemem(x)
```

If only one name points to an object, R can usually **modify it in place** without copying -- that's what's happening in the last line.

This has some practical consequences:

- Passing an object to a function does not copy it. R copies the object
  only if the function modifies it.
- Every copy takes time and memory. A copy inside a loop is made on every
  iteration, so loops are where copies cost the most.
- Memory used by an object is freed automatically once no name points to
  it. R's *garbage collector* does this in the background, so you rarely
  need to call `gc()` yourself.

::: callout
RStudio's Environment pane holds its own references to objects. This can
make `tracemem()` report copies you wouldn't see if you ran R in a
terminal or rendered an R Markdown/Quarto document.
:::

## Avoid creating unnecessary objects

Here are some tips to avoid creating objects unnecessarily:

- Re-use temporary variable names, e.g. `x <- x + 1` instead of
  `y <- x + 1`. The old value of `x` then has no name pointing to it, so its
  memory can be freed.
- Don't save intermediate results unnecessarily; compute them on the fly.
- Use `rm()` to remove large objects when they are no longer needed. This
  removes the name, so the garbage collector can free the memory.
- Cache variables: calculate an object once and reuse the value when
  necessary. For example, if `sd(x)` appears in several function calls,
  define `sd_x <- sd(x)` once and reuse it.

## Data structures

Use the simplest data structure that does the job. This minimises the
amount of memory you need and the work R has to do. For example:

- If you have rectangular data of the same type, prefer a matrix to a data
  frame.
- Use logical or integer vectors instead of numeric (double) vectors where
  possible. They need 4 bytes per element instead of 8.
- Use unnamed objects instead of named objects.

It is especially important to use low-level structures for computation.
You can create richer objects as a final step before returning them to the
user.

::: callout
Data frames are lists of columns. Modifying one column copies only that
column, but modifying a **row** copies **every** column. If you need to
update data row by row in a loop, work on a matrix or on separate vectors
instead, and build the data frame at the end.
:::

## Don't grow objects

In R, growing objects with a loop is notoriously slow. When you use `c()`,
`append()`, `cbind()`, `rbind()` or `paste()` to make an object bigger, R
can't extend the existing object in place. It must allocate space for a new
object and copy the old one into it. Repeating this on every iteration
means copying more and more data each time, so the total work grows with
the *square* of the final length.

Let's compare three ways of creating a sequence of numbers. We will wrap
each one in a function, to make it easier to benchmark their performance.

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

Method 2: create an object of the final length, then change its values by
subsetting:


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
`numeric(n)`, `integer(n)`, `logical(n)` and `character(n)` initialise
vectors of length `n` of the type given as the function name. To initialise
a list, we can use `vector(mode = "list", length = n)`.
:::

Method 3: create the final object directly


``` r
direct <- function(n) {
   seq_len(n)
}
```

::: callout
Note that many sequences can be created directly with `seq()` and `rep()`.
See their help pages to learn about all their arguments.
:::

:::::: challenge
Which of `grow()`, `pre_allocate()` and `direct()` do you expect to perform
best and why? Which of the methods do you think will scale best as `n`
increases? Which do you think will scale worst?

Use microbenchmarking to test your intuition. Try different values of `n`.
At what size do you start to notice differences?

::: hint
In which method do you get to the underlying C code the fastest?

Which method(s) create copies? In which method(s) are objects modified in place?
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
1 grow(n)            102ms    107ms       9.25     382MB    96.2 
2 pre_allocate(n)    407µs    413µs    2346.      98.6KB     4.00
3 direct(n)          450ns    591ns 1207034.          0B     0   
```

Note the orders of magnitude difference in the results. `pre_allocate(10000)`
is over 300 times faster than `grow(10000)`. Where it is possible to
directly specify your vector, that is orders of magnitude faster again. In
this case, `direct(10000)` is nearly 1500 times faster than
`pre_allocate(10000)`. That's quite the speed-up!

Look at the `mem_alloc` column too. `grow()` allocates far more memory than
the size of its final result, because it makes a new copy on every
iteration.

When `n <- 10000000`, method 1 takes about an hour, whereas method 3 is
pretty much instantaneous.


:::

::::::


::::::::::::::::::::::::::::::::::::: keypoints

- Names point to objects in memory. R copies an object only when you modify one that has more than one name (copy-on-modify).
- Use `tracemem()` to see when R copies an object.
- Avoid creating objects unnecessarily.
- Use the simplest data structure for your needs.
- Do not grow objects. Create them directly if you can. Otherwise, pre-allocate the memory before running a loop.

::::::::::::::::::::::::::::::::::::::::::::::::


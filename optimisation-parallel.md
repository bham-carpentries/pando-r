---
title: 'Parallel computing'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- When can parallelising code lead to performance improvements, and when does it not?
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain what parallel computing is
- Use the `futurize` package to parallelise code

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

Parallel computing is the practice of splitting a task into smaller pieces that run at the same time on multiple CPU cores, rather than one after another on a single core. This can speed up processing time. Most modern laptops have several cores, but R uses only one by default. Code that repeats the same independent operation many times, such as fitting a model to each of many bootstrap samples or processing a large set of files, can often run several times faster in parallel. 

Parallelisation is most straight-forward to implement for embarrassingly parallel problems, such as applying a function to elements of a list.

::: callout
A task is embarrassingly parallel when it splits into pieces that are fully independent of each other: no piece needs another’s results, and the pieces don’t need to communicate while they run. Each piece can go to a separate worker with almost no coordination, and the results are combined only at the end.
:::

Parallelism isn’t free, though: setting up workers and moving data between them adds overhead, so the challenge is knowing when it will actually pay off.

## `futurize`

The [futureverse](https://www.futureverse.org) is an ecosystem of R packages for parallelising R code. Its goal is to lower the barrier so that anyone can speed up their existing R code in a worry-free manner. The new [**futurize**](https://futurize.futureverse.org) package makes it extremely simple to parallelize your existing map-reduce calls, but also a growing set of domain-specific calls. All you need to know is that there is a single function called `futurize()` that will take care of everything.

::: callout
Map-reduce is a pattern in two steps. In the **map** step, the same function is applied independently to each element of a collection. In the **reduce** step, the separate results are combined into one output. Common map-reduce functions in R are the `apply()` family, `purrr::map()` and its variants, and `foreach()`. Because the iterations don’t depend on each other, they are natural candidates for parallelisation.
:::

## Using futurize


``` r
library(futurize)
```

``` output
Loading required package: future
```

``` r
library(tictoc)
```

With futurize, you can take existing map-reduce code and parallelise it with two additional lines:

```r
plan(multisession)                        # once, at the top of your script

ys <- lapply(xs, slow_fcn)                # sequential, as before
ys <- lapply(xs, slow_fcn) |> futurize()  # the same, now in parallel
```

The call to `plan(multisession)` sets up parallelisation on a local computer, using available cores. Then all you need to do is pipe your existing map-reduce code into `futurize()`. It really is that simple.

::: callout
As well as on your local machine, **futurize** can also be used across machines on your local network, in the cloud, or on a high-performance compute (HPC) cluster. See the documentation for [`plan()`](https://future.futureverse.org/reference/plan.html) for other set-ups.
:::

Let's demonstate this with a `slow_sum()` function, and use the **tictoc** package to time it.


``` r
slow_sum <- function(x) {
   sum <- 0

   for (value in x) {
      Sys.sleep(0.5)  ## half-second slowdown per value
      sum <- sum + value
   }

   sum
}
```


``` r
library(tictoc)
tic()
y <- slow_sum(1:10)
toc()
```

``` output
5.009 sec elapsed
```

Now suppose we have four sets of numeric vectors, in a list, and we want to calculate slow_sum() for each:


``` r
xs <- list(1:10, 11:20, 21:30, 31:40)
```

We could run `lapply()` over this, but it takes a while as it handles each list item in turn:


``` r
tic()
ys <- lapply(xs, slow_sum)
toc()
```

``` output
20.023 sec elapsed
```

Instead, we can parallelise with `futurize()`:


``` r
plan(multisession, workers = 4) # only need 4 cores, as 4 items in the list
```

``` error
Error in `checkNumberOfLocalWorkers()`:
! Attempting to set up 4 localhost parallel workers with only 1 CPU cores available for this R process (per 'cgroups2.cpu.max'), which could result in a 400% load. The hard limit is set to 300%. Overusing the CPUs has negative impact on the current R process, but also on all other processes of yours and others running on the same machine. See help("parallelly.maxWorkers.localhost", package = "parallelly") for further explanations and how to override the hard limit that triggered this error. By the way, was parallel::detectCores() used, because the number of workers (4) equals detectCores()? If so, please use parallelly::availableCores() instead
```

``` r
tic()
ys <- lapply(xs, slow_sum) |> futurize()
```

``` error
Error in `stop_with_version()`:
! [futurize 1.1.0] Function base::lapply() is not in one of the registered futurize namespaces: 
```

``` r
toc()
```

``` output
0.017 sec elapsed
```

The four slow sums are calculated in about the same time as it takes to calculate one, since they are being calculated simultaneously on separate cores.

:::::: challenge
The [**efficient**](https://github.com/csgillespie/efficient) package contains a function to simulate a game of snakes and ladders, returning the number of rolls required to win.

Parallelise the following code:


``` r
library(efficient)
N <- 100
nrolls <- sapply(seq_len(N), snakes_ladders)
```

Use **tictoc** to compare the run-times. Roughly how large does N have to be for the parallel version to be worth using?

::: solution


``` r
N <- 200 # experiment with changing this
tic()
nrolls <- sapply(seq_len(N), snakes_ladders)
toc()
```

``` output
0.067 sec elapsed
```

``` r
tic()
nrolls <- sapply(seq_len(N), snakes_ladders) |> futurize(future.seed = TRUE)
```

``` error
Error in `stop_with_version()`:
! [futurize 1.1.0] Function base::sapply() is not in one of the registered futurize namespaces: 
```

``` r
toc()
```

``` output
0.012 sec elapsed
```

When `N` is 200, the two are equivalent (on a M5 MacBook Pro). When `N` is greater than that, the parallel version is faster. When `N` is less, the sequential version is faster - the overheads of setting up the parallelisation outweigh the benefits of multiple cores.

:::

::::::

::::::::::::::::::::::::::::::::::::: keypoints 

- Parallelising code can speed up the wall time
- The **futurize** package makes it incredibly simple to parallelise map-reduce code

::::::::::::::::::::::::::::::::::::::::::::::::


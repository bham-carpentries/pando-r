---
title: 'Introduction to optimisation'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why could optimisation of code be harmful?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain the cost benefit analysis of performing code optimisation
- Explain why it is important to write tests for code before optimising
- Write simple tests with **tinytest**

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

<!-- Enable you to look at hotspots identified by profiler, identify whether it's efficient -->
Now that you're able to find the most expensive components of your code with profiling, we can think about ways to improve it.
However, the best way to do this will depend a lot on your specific code! For example, if your code is spending 60 seconds waiting to download data files and then 1 second to analyse that data, then optimizing your data analysis code won’t make much of a difference. We will assume there are no such external bottlenecks and look at the performance of your code.

<!-- Necessary to understand how code executes (to a degree) -->
In order to optimise code for performance, it is necessary to have an understanding of what a computer is doing to execute it.

<!-- Goal is to give you a high level understanding of how your code executes. You don't need to be an expert, even a vague general understanding will leave you in a stronger position. -->
A high-level understanding of how your code executes, such as how R and the most common data-structures and algorithms are implemented, can help you identify suboptimal approaches when programming. If you have learned to write code informally out of necessity, to get something to work, it's not uncommon to have collected some habits along the way that may harm your code's performance.

<!-- This should be considered good practice that you can implement when first writing your code. -->
These are the first steps in code optimisation, and knowledge you can put into practice by making more informed choices as you write your code and after profiling it.

<!-- This is largely high-level/abstract knowledge applicable to the vast majority of programming languages -->
The remaining content is often abstract knowledge which is transferable to many programming languages. This is because the hardware architecture, data-structures and algorithms used are common to many languages and they hold some of the greatest influence over performance bottlenecks.

## Performance vs Maintainability

> Programmers waste enormous amounts of time thinking about, or worrying about, the speed of non-critical parts of their programs, and these attempts at efficiency actually have a strong negative impact when debugging and maintenance are considered. We should forget about small efficiencies, say about 97% of the time: **premature optimization is the root of all evil**. Yet we should not pass up our opportunities in that critical 3%. - Donald Knuth

This classic quote among computer scientists emphasises the importance of considering both performance and maintainability when optimising code and prioritising your optimisations.

While advanced optimisations may boost performance, they often come at the cost of making the code harder to understand and maintain. Even if you're working alone on private code, your future self should be able to easily understand the implementation. Hence, when optimising, always weigh the potential impact on both performance and maintainability. While this course does not cover most advanced optimisations, you may already be familiar with and using some.

Profiling is a valuable tool for prioritising optimisations. Should effort be expended to optimise a component which occupies 1% of the runtime? Or would that time be better spent optimising the most expensive components?

This doesn't mean you should ignore performance when initially writing code. Choosing the right algorithms and data structures, as we will discuss in this course, is good practice. However, there's no need to obsess over micro-optimising every tiny component of your code. Focus on the bigger picture.

## Performance of R

If you've read about different programming languages, you may have heard that there’s a difference between "interpreted" languages (like R) and "compiled" languages (like C). You may have heard that R is slow *because* it is an interpreted language. To understand where this comes from (and how to get around it), let's talk a little bit about how R works.

In C, integers (or other basic types) are raw data in memory. It is up to the programmer to keep track of the data type.
The compiler can then turn the source code directly into machine code. This allows the compiler to perform low-level optimisations that better exploit hardware nuance to achieve fast performance. This however comes at the cost of compiled software not being cross-platform.

```C
/* C code */
int a = 1;
int b = 2;
int c = a + b
```

In R, everything is an object. The interpreter uses extra fields in the header to keep track of data types at runtime and take care of memory management.
This adds a lot more flexibility and makes life easier for programmers. However, it comes at the cost of some overhead in both time and memory usage. 
Compiled languages also require the programmer to take care of memory management, which can be error-prone in C, and mistakes can introduce subtle and costly bugs.

```r
# R code
a <- 1 # no need to specify object type
b <- 2
c <- a + b
```
::::::::::::::::::::::::::::::::::::: callout

Objects store both their raw data (like an integer or string) and some internal information used by the interpreter. We can use `lobstr::obj_size()` to see how much storage an R object takes:


``` r
lobstr::obj_size(1L) # The L makes the 1 an integer rather than a double
```

``` output
56 B
```

An integer in R uses 56 bytes, far more than the 4 bytes an `int` uses in C.

::::::::::::::::::::::::::::

We effectively gain programmer performance by sacrificing some code performance. Most of the time, computers are "fast enough" so this is the right trade-off, as Donald Knuth said.

However, there are the few other cases where code performance really matters. To handle these cases, R has the capability to integrate with code written in lower-level programming language (like C, C++, Fortran or Rust) under the hood.
Some performance-sensitive packages, such as **data.table** and **dplyr** therefore perform a lot of the work in such low-level code, before returning an R object back to you.

Therefore, **it is often best to tell the interpreter/library at a high level *what you want*, and let it figure out *how to do it*.**

That way, the interpreter/library is free to do all its work in the low-level code, and adds overhead only once, when it creates and returns an R object in the end.
This usually makes your code more readable, too. When someone else reads your code, they can see exactly *what you want to do*, without getting overwhelmed by overly detailed step-by-step instructions.

## Ensuring reproducible results

<!-- This is also good practice when optimising your code, to ensure mistakes aren't made -->
When optimising existing code, you often make speculative changes, which can lead to subtle mistakes. You should only optimise code once you are sure your existing code produces correct results. To ensure that your optimisations are not also introducing errors, it is crucial to have a strategy for checking that the results remain correct.

Testing should already be an integral part of your development process. It helps clarify expected behaviour, ensures new features are working as intended, and protects against unintended regressions in previously working functionality. Always verify your changes through testing to ensure that the optimisations don’t compromise the correctness of your code.

## Overview of testing in R

There are a couple of excellent R packages for testing code with unit tests.
If you are writing your code as part of a package, the infrastructure provided by [**testthat**](https://testthat.r-lib.org) package is very good and very easy to use, particularly in conjunction with the [**usethis**](https://usethis.r-lib.org) package. The [testing basics chapter](https://r-pkgs.org/testing-basics.html) in the R Packages book gives a good introduction. 

For getting started with unit testing in R, there is also the low-dependency [**tinytest**](https://github.com/markvanderloo/tinytest) package, which is easy to use within individual R scripts, as well as in packages.

## Brief introduction to **tinytest**

In **tinytest**, tests are simple R scripts where test statements can be interspersed with other code (e.g. to prepare some results for testing). The purpose of testing is to gather evidence (data) that builds confidence in the quality of software. Unit tests consist of expressions where an expected result is compared with the result of a program or function. The test `expect_equal()` (and other `expect_*()` [tests provided by tinytest](https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md)) show whether the test passed or failed, with useful information if there is a failure.


``` r
library(tinytest)
add_one <- function(x) x + 1
sub_one <- function(x) x - 2 # deliberate mistake (to catch with a test)

# this test should pass
expect_equal(add_one(1), 2)
```

``` output
----- PASSED      : <-->
 call| expect_equal(add_one(1), 2) 
```

``` r
# this test will fail
expect_equal(sub_one(2), 1) 
```

``` output
----- FAILED[data]: <-->
 call| expect_equal(sub_one(2), 1)
 diff| Expected '1', got '0' 
```

In **tinytest**, the `expect_*()` functions evaluate to a boolean, rather than the **testthat** approach of causing an exception (i.e., stopping the evaluation of the script):


``` r
isTRUE(expect_equal(add_one(1), 2))
```

``` output
[1] TRUE
```

``` r
isTRUE(expect_equal(sub_one(2), 1))
```

``` output
[1] FALSE
```

If you have passing tests for `some_function()`, when you optimise the code inside `some_function()`, rerunning the tests on the updated implemantation gives you the data you need to be confident that the optimisations have not introduced bugs into the code, leading to incorrect results (or, if the tests now fail, you know the function implementation needs correcting).

::: challenge
Here are two functions and (part-written) associated tests. Which functions from the `expect_*()` family do you need to make these tests pass?

```r
is_bigger <- function(a, b) {
  a > b
}

greeting <- function(name) {
  stopifnot(is.character(name))
  paste("Hello", name)
}

expect_*(is_bigger(6, 3))
expect_*(greeting(6))
expect_*(greeting("Ella"), "Hello Ella")
```

::: hint
The functions in the `expect_*()` family are listed in the [tinytest documentation](https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md)
:::

::: solution
- `expect_true(is_bigger(6, 3))`
- `expect_error(greeting(6))`
- `expect_equal(greeting("Ella"), "Hello Ella")` (`expect_identical()` and `expect_equivalent()` also pass)
:::

:::

::::::::::::::::::::::::::::::::::::: keypoints 

- When considering optimisation it is important to focus on the potential impact, both to the performance and maintainability of the code.
- Write tests to ensure that an expression or function produces an expected/correct output, then rerun the tests after any changes to the implementation of the functions, to ensure the output is still correct.

::::::::::::::::::::::::::::::::::::::::::::::::


---
title: 'Next steps'
teaching: 10
exercises: 0
---

:::::::::::::::::::::::::::::::::::::: questions 

- Where can I learn more?
- What can I do if I've optimised my R code but it is still too slow?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Recognise when optimisation options in R have been exhausted
- Be aware that rewritting bottleneck code in Rust or C++ can bring significant improvements
- Be aware that compiled code can be called from R
- Identify resources for learning more about profiling and optimisation

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

It may be that you have profiled your code, identified bottlenecks, and optimised your computational approach accordingly, but your code is still slow. Or perhaps you could speed up your implementation in R, but the resulting code would be obscure, convoluted and difficult to read or follow. 

What can you do next?

## Further R optimisations

This course is only a day long, and limited in what we can cover in that time. 
There are further optimisations in R beyond the material presented here. In particular, the following two books provide a deeper understanding of R, and suggest further optimisations. They are both freely available online.

- [Advanced R](https://adv-r.hadley.nz), by Hadley Wickham. The chapter on [improving performance](https://adv-r.hadley.nz/perf-improve.html) is particularly relevant.
- [Efficient R Programming](https://csgillespie.github.io/efficientR/) by Colin Gillespie & Robin Lovelace, especially the chapters on [programming](https://csgillespie.github.io/efficientR/programming.html) and [optimisation](https://csgillespie.github.io/efficientR/performance.html).

## Rewriting R code in a compiled language

Sometimes, you reach the limit of performance in R.

Then, it can make sense to rewrite the remaining slow parts of your code in a compiled language, such as C++ or Rust, and call it from R. 

::: callout
We already discussed in the [Introduction to Optimisation](episodes/optimisation-introduction.Rmd) that compiled code runs faster than an interpreted language like R. In [Base R Optimisations](episodes/optimisation-base-r.Rmd) we noted that you should try to reach R's underlying compiled code as quickly as possible, and that many R packages contain compiled code. When already existing compiled code available in R doesn't solve your problem, writing your own compiled code and calling it from R can be the logical the next step.
:::

The details of how to do this are beyond the scope of this lesson, but there are a couple of options to be aware of, and we provide links to further details.

### C++ with Rcpp

C++ is an extension of C, though with better memory management and with a large standard library of ready-made building blocks. For R users, C++ is a better choice than C because of the [**Rcpp**](https://www.rcpp.org) package, which enables seamless R and C++ integration. Rcpp also provides "syntactic sugar", enabling you to write C++ code that looks and behaves more like R code (for example, with vectorisation). Both C++ and Rcpp have been around for many years (C++ since 1985, Rcpp has been on CRAN since 2005). It's a mature ecosystem. Rcpp is used by over 3000 packages on CRAN. There are many resources, tutorials, and examples available. The package vignettes, available in R through `browseVignettes("Rcpp")` or via the [Rcpp CRAN page](https://CRAN.R-project.org/package=Rcpp) are a good place to start. See the [Rcpp gallery](https://gallery.rcpp.org) for many more resources. 

### Rust with rextendr

[Rust](https://rust-lang.org) is a newer compiled language, with version 1.0 released in 2015. It interfaces with R through the [rextendr](https://extendr.rs/rextendr/) package. Rust offers a number of advantages over C++, particularly around memory safety. It has helpful error messages, built-in tooling, and less historical baggage. There are trade-offs, though. Compared to C++, it is thought to be harder to learn at first, though there is excellent [documentation](https://rust-lang.org/learn/) and an interactive learning experience through [rustlings](https://rustlings.rust-lang.org). Being much newer than C++/Rcpp, the ecosystem is much smaller. 


::::::::::::::::::::::::::::::::::::: keypoints 

- Advanced R and Efficient R Programme are excellent books from which to learn more on the topics covered in this lesson
- When you have exhausted optimisation options in R, rewrite the bottleneck parts of your code in a compiled language and interface to it in R (either C++ with Rcpp or Rust with rextendr)

::::::::::::::::::::::::::::::::::::::::::::::::


---
site: sandpaper::sandpaper_site
---

::: callout
This course is still under active development.
:::

**Welcome to Performance Profiling & Optimisation (R) Training!**

This course is designed for researchers who want to write efficient R code. It focuses on practical skills for identifying computationally expensive functions and lines of code through profiling, applying best practices for writing performant code, and measuring improvements through benchmarking. You may already be working with large datasets, complex simulations, or have R scripts which take a while to run and you expect that it is possible that the code could be faster. Whether you want to speed up your code because you are frustrated with its slowness, care about the environmental impact of compute, or because you want to reduce the resources you require on HPC, this course will help you adopt coding practices that are more efficient and sustainable.

If you are comfortable using R but lack formal computer science training. this course may be of interest to supplement and advance your programming knowledge. This course is particularly relevant if you are writing research code and desire greater confidence that your code is both performant and suitable for publication.

## Motivation

Why might you want to profile and optimise your code?

The simplest answer is that optimisation let you get results faster. It may also allow you to scale up your code to perform larger analyses that would otherwise have taken too long to be practical.

Making your code faster can have additional benefits: faster software uses less compute power. If you use paid-for compute resources, such as cloud computing or some HPC facilities, optimising your code can therefore reduce your costs.

Using less computing power also helps make your software more environmentally sustainable. As funders and research institutions set Net Zero goals, and computationally-intensive research expands, sustainability is increasingly becoming a concern for researchers.

::::::::::::::::::::::::::::::::::::: callout

### Green computing

To find out more about sustainable computing, visit the [Green DiSC](https://www.software.ac.uk/GreenDiSC) website or see this [online training](https://learn.greensoftware.foundation/) from the Green Software Foundation.

:::::::::::::::::::::::::::::::::::::

It is sensible to focus your optimisation efforts on the parts of the code that take the longest. This is where profiling comes in: by profiling your code, you can identify which parts contribute the most to its runtime, and target these for optimisation.

Even if you don’t find any major performance gains, profiling can give you a better understanding of what your code is doing, or give you confidence that the performance of your code matches your expectations.

## Learning objectives

After attending this training, participants will be able to:

- Identify the most computationally expensive functions and lines of code in an R script using the [**profvis**](https://profvis.r-lib.org) package
- Use the [**bench**](https://bench.r-lib.org/) package to compare the execution time of different R expressions that produce the same result
- Identify coding patterns in R that are known to cause slow performance
- Rewrite a profiled bottleneck using established optimisation techniques so that it runs faster without changing its output

::: prereq
Learners should have **at least six months of experience using R** and be comfortable with:

- Writing and running R scripts
- R data structures, such as vectors, matrices, lists and data frames
- Writing and using functions
- Installing and using R packages
- Familiarity with an IDE (the course will be taught in RStudio)
:::

## Acknowledgments

This lesson is adapted from [Performance Profiling and Optimisation (Python)](https://carpentries-incubator.github.io/pando-python/). The R-specific content draws heavily from material in [Advanced R](https://adv-r.hadley.nz) by Hadley Wickham and [Efficient R Programming](https://csgillespie.github.io/efficientR/) by Colin Gillespie & Robin Lovelace.
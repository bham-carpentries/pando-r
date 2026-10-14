---
title: 'Introduction to Profiling'
teaching: 15
exercises: 5
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why should you profile your code?
- What are the options for profiling in R?
- Which test case should be profiled?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

* Explain the benefits of profiling code
* Differentiate between types of profiler
* Explain how to select an appropriate test case for profiling

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

<!-- Profiling is (what) -->
Performance profiling is the process of analysing and measuring the performance of a program or script during its execution. Here, performance means how efficiently your code uses resources, especially **time** (how long it takes to run) and **memory** (how much RAM it needs), to produce a correct result.

<!-- It can be used for (where) -->
Good performance is fast enough for your purposes, rather than necessarily as fast as possible. Profiling is useful when you have written any code that will be running for a substantial period of time. As your code grows in complexity, it becomes increasingly difficult to estimate where time is being spent during execution. Profiling allows you to measure and visualise where the time is being spent, and therefore where to focus your efforts on optimising your code for performance speed-ups.

<!-- This allows enables faster/more (why) -->
Profiling is a relatively quick process which can either provide you the peace of mind that your code is efficient, or highlight any performance bottlenecks. There is limited benefit to optimising components that may only contribute a tiny proportion of the overall runtime. Identifying bottlenecks allows optimisation to be precise and efficient, potentially leading to significant speed-ups enabling faster research. In extreme cases, addressing bottlenecks has enabled programs to run hundreds or thousands of times faster!

<!-- Increasingly, concern for green/eco compute and or cloud costs (why) -->
Increasingly, particularly with relation to HPC, attention is being paid to the energy usage of software. Profiling your software will provide you the confidence that your software is an efficient use of resources.

## When to profile

Profiling is most relevant to working code, when you have reached a stage that the code works, i.e. produces correct results, and are considering deploying it.

Any code that will run for more than a few minutes over its lifetime and isn’t a quick one-off script can benefit from profiling.

::::::::::::::::::::::::::::::::::::: callout

## All Programmers Can Benefit

<!-- Everyone benefits (why) -->
Even professional programmers make oversights that can lead to poor performance, and can be identified through profiling.

For example Grand Theft Auto Online, which has allegedly earned over $7bn since its 2013 release, was notorious for slow loading times.
8 years after its release [a 'hacker'](https://nee.lv/2021/02/28/How-I-cut-GTA-Online-loading-times-by-70/) had enough, they reverse engineered and profiled the code to enable a 70% speedup!

*How much revenue did that unnecessary bottleneck cost, through user churn?*

*How much time and energy was wasted, by unnecessarily slow loading screens?*

::: instructor

The bottlenecked implementation was naively parsing a 10MB JSON file to create a list of unique items.

Repeatedly:

* Checking the length of (C) strings, e.g. iterating till the terminating character is found, resolved by caching the results.
* Performing a linear search of a list to check for duplicates before inserting, resolved by using an appropriate data structure (dictionary).
    * Allegedly duplicates were never even present in the JSON.

Why wasn't this caught by one of the hundreds of developers with access to the source code?

Was more money saved by not investigating performance than committing time to profiling and fixing the issue?

:::
:::::::::::::::::::::::::::::::::::::::::::::

## Types of profiler

There are multiple approaches to profiling. Most programming languages have one or more tools available covering these approaches. Whilst these tools differ, their core functionality can be grouped into several categories.

### Manual profiling

Similar to using `print()` for debugging, manually timing sections of code can provide a rudimentary form of profiling.

```R
t_a <- proc.time()[["elapsed"]]
# A: Do something
t_b <- proc.time()[["elapsed"]]
# B: Do something else
t_c <- proc.time()[["elapsed"]]
# C: Do another thing
t_d <- proc.time()[["elapsed"]]

paste("A:", t_b - t_a, "seconds")
paste("B:", t_c - t_b, "seconds")
paste("C:", t_d - t_c, "seconds")
```

*Above is only one example of how you could manually profile your R code. There are other similar techniques.*

Whilst this can be appropriate for profiling narrow sections of code, it becomes increasingly impractical as a project grows in size and complexity.

Furthermore, it's also unproductive to be routinely adding and removing these small changes if they interfere with the required outputs of a project.

::: callout
We can use benchmarking to more accurately time our code. We will return to this in the episode on [microbenchmarking](microbenchmarking.Rmd).
:::

### Function-level profiling and line-level profiling

Software is typically comprised of a hierarchy of function calls, both functions written by the developer and those used from the language’s standard library and third party packages.

Function-level profiling analyses where time is being spent with respect to functions. Typically, function-level profiling will calculate the number of times each function is called and the total time spent executing each function, inclusive and exclusive of child function calls.

This allows functions that occupy a disproportionate amount of the total runtime to be quickly identified and investigated.

Line-level profiling provides greater granularity, analysing where time is being spent with respect to individual lines of code. This will identify individual lines of code that occupy an disproportionate amount of the total runtime.

::: callout
If you are familiar with other programming languages, you may be aware that they may have different tools for function-level and line-level profiling (e.g. Python has **cProfile** for function-level profiling and **line_profiler** for line-level profiling, as well as different packages for visualising, e.g. **snakeviz** and **viztracer**). However, in R, we have one main package for profiling, **profvis**, which combines both function-level and line-level profiling, as well as the timing and the visualisation. Working with **profvis** is the subject of the [next episode](profiling-profvis.md).
:::

## Selecting an appropriate test case

<!-- Profiling runs slower -->
The act of profiling your code, collecting additional timing metrics during execution, will cause your program to execute slower. The slowdown is dependent on many variables related to both your code and the granularity of metrics being collected.

<!-- Profiling may generate large amounts of data -->
Similarly, the longer your code runs, the more code that is being executed, the more data that will be collected. A profile that runs for hours could produce gigabytes of output data!

<!-- Important to select appropriate test-case/s -->
Therefore, it is important to select an appropriate test-case that is both representative of a typical workload and small enough that it can be quickly iterated. 
Ideally, it should take no more than a few minutes to run the profiled test-case from start to finish, however you may have circumstances where something that short is not possible. Be aware, though, that if the test case runs too quickly, or is too small, it may not reveal the bottlenecks that affect the full run.

<!-- For example -->
<!-- I don't really like this paragraph -->
For example, you may have a model which normally simulates a year in hourly time-steps.
It would be appropriate to begin by profiling the simulation of a single day.
If the model scales over time, such as due to population growth, it may be pertinent to profile a single day later into a simulation if the model can be resumed or configured.
A larger population is likely to amplify any bottlenecks that scale with the population, making them easier to identify.

::::::::::::::::::::::::::::::::::::: discussion

## Exercise (5 minutes)

Think about a project where you've been working with R.
Do you know where the time during execution is being spent?

Write a short plan of the approach you would take to investigate and confirm where the majority of time is being spent during its execution.

<!-- TODO should they share this anywhere, should it be discussed within the group? -->

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: hint

- What tools and techniques would be required?
- Is there a clear priority to these approaches?
- Which test-case/s would be appropriate?

::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: keypoints 

- Profiling is a relatively quick process to analyse where time is being spent and identify bottlenecks during a program's execution.
- Code should be profiled when ready for deployment if it will be running for more than a few minutes during its lifetime.
- There are several types of profiler each with slightly different purposes.
- The standard package for profiling in R is **profvis**.
- A representative test-case should be profiled. It should be large enough to amplify any bottlenecks whilst executing to completion quickly.

::::::::::::::::::::::::::::::::::::::::::::::::


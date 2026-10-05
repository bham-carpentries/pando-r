---
title: 'Introduction to Profiling'
teaching: 15
exercises: 10 # FIXME
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


::::::::::::::::::::::::::::::::::::: discussion

# Exercise (5 minutes)

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


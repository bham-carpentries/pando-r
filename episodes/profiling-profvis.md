---
title: 'Profiling with profvis'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can the **profvis** package be used to profile an R program?
- How can the output from `profvis()` be interpreted?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how **profvis** profiles R code 
- Use **profvis** in RStudio to visualise profiling information for an R script
- Interpret **profvis** views to identify the functions where time is being spent during a script's execution
- Interpret **profvis** views to identify the functions which result in heavy memory allocation

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

::::::::::::::::::::::::::::::::::::: challenge 

## Challenge 1: Can you do it?

What is the output of this command?

```r
paste("This", "new", "lesson", "looks", "good")
```

:::::::::::::::::::::::: solution 

## Output
 
```output
[1] "This new lesson looks good"
```

:::::::::::::::::::::::::::::::::


## Challenge 2: how do you nest solutions within challenge blocks?

:::::::::::::::::::::::: solution 

You can add a line with at least three colons and a `solution` tag.

:::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: keypoints 

- R code can be profiled with the `profvis()` function from the **profvis** package
- Profiling output displays... **SOMETHING ABOUT THE FLAME GRAPH**
- Profiling output displays... **SOMETHING ABOUT MEMORY AND TIME**
::::::::::::::::::::::::::::::::::::::::::::::::


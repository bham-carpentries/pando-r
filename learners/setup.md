---
title: Setup
---


## Software Setup

::::::::::::::::::::::::::::::::::::::: discussion

This lesson assumes you have R and RStudio installed on your computer.
Please follow the setup instructions below.


:::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::: spoiler

### Personal Laptop

To install R and RStudio on a personal laptop

#### Windows/Mac

- [R can be downloaded here](https://cran.ma.imperial.ac.uk). Select the precompiled binary distribution for your operating system.

- RStudio is an environment for code development using R. [RStudio can be downloaded here](https://docs.posit.co/ide/user/download.html). You will need the Desktop version for your computer.

::::::::::::::::::::::::

:::::::::::::::: spoiler

### University of Birmingham Managed Laptop

#### Windows
To install R and RStudio on a University managed Windows machine:

- Connect your computer to the university network and open the Software Centre from the Start Menu

- Search for and install "RStudio". 

- This will also automatically install R for Windows and Rtools.

#### Mac

To install R and RStudio on a University managed Mac machine:

- Connect your computer to the university network and open the Software Centre from the Start Menu

- Search for and install "R Language". 

- Search for and install "RStudio". 

::::::::::::::::::::::::

## Packages

This course requires a number of R packages, which should be installed in advance. You can do this by starting RStudio, and entering:

```r
install.packages(c("profvis", "bench", "tinytest", "futurize", "tictoc"))
```

Additionally, you need to have the following pacakges installed. We won't be using them directly, but they are needed to create plots with **bench**:

```r
install.packages(c("ggplot2", "ggbeeswarm", "tidyr"))
```

We will also use the [**efficient**](https://github.com/csgillespie/efficient) package. It can be installed directly from GitHub, which should be done by:

```r
install.packages("remotes")
remotes::install_github("csgillespie/efficient",
                         INSTALL_opts = "--with-keep.source")
```
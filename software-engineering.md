---
title: 'Good software engineering practices'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why would a newer version of R or a package be faster?
- Are there any risks to updating R and packages?
- Are faster implementations already available?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain why using the latest versions of R and R packages is benefical
- Search for existing solutions

::::::::::::::::::::::::::::::::::::::::::::::::

## Keep R up to date

<!-- Why it's important to use the most recent R and packages viable -->
It's good practice to use a recent version of R. As well as new features and bug fixes,
several releases have brought significant performance improvements. R 3.4.0 (2017) enabled the just-in-time byte-code compiler by default, so loops and functions are compiled automatically, and R 3.5.0 (2018) introduced ALTREP, which avoids allocating memory for large vectors such as `1:1e9` until it's needed. Since then, gains have been more incremental and specific to particular functions, rather than across-the-board speedups. 

Similarly, major packages with a performance focus should be kept up to date, as their developers implement speed-ups. 

## Keep packages up to date

The same advice applies to packages as to R itself: newer versions are often faster, sometimes dramatically so, with no change to your code. Package developers regularly rewrite slow functions in C or C++, or switch to better algorithms. Some recent examples from widely used packages:

* **dplyr 1.2.0 (2026)**: `if_else()` and `case_when()` were rewritten in C (via the vctrs package), making them up to 30x faster and using up to 10x less memory. `coalesce()` was sped up in the same way.
* **dplyr 1.1.0 (2023)**: `arrange()` switched to a radix sort algorithm (borrowed from
  data.table), making sorting character columns up to 100x faster. Note that this release also changed the *default sort order* for strings to the "C" locale, so uppercase letters now sort before lowercase. Use `arrange(.locale = "en")` if you need the old behaviour.
* **readr 2.0.0 (2021)**: `read_csv()` and friends switched to the vroom engine, which reads files using multiple threads, so reading large files is considerably faster.

You can check which version of a package you have with `packageVersion("dplyr")`, and update all your packages with `update.packages()`. Tidyverse package releases are often described on the [tidyverse blog](https://www.tidyverse.org/blog/), which is a good place to look for news of performance improvements.

Before updating, it's worth checking the release notes: major releases occasionally change behaviour (as with the `arrange()` sort order above), and that can matter more than the speed-up if you need results to be reproducible.

## Check for existing solutions

There are over 25000 packages on CRAN, and there may already be existing solutions that address the same performance bottleneck that you are experiencing. [CRAN task views](https://cran.rstudio.com/web/views/) are a good place to look for packages related to particular problem domains. The [high performance and parallel computing with R](https://cran.rstudio.com/web/views/HighPerformanceComputing.html) task view in particular lists many packages where performance is optimised. 

Packages that depend on or import [**Rcpp**](https://CRAN.R-project.org/package=Rcpp) or [**cpp11**](https://CRAN.R-project.org/package=cpp11) are also likely to be fast, since they use C++. You can find all the packages that depend on **Rcpp** by looking at the reverse depends and reverse imports on the [Rcpp CRAN page](https://CRAN.R-project.org/package=Rcpp) (and similarly for **cpp11**). Going in the other direction, a package that lists **Rcpp** or *cpp11** under "Depends" or "Imports" in its DESCRIPTION file/on its CRAN page, is likely to be efficient.

## Linear algebra and BLAS

Many operations in R, such as matrix multiplication (`%*%`), `crossprod()`, `solve()`,
`chol()` and model fitting with `lm()`, hand the actual number crunching to two standard
libraries: BLAS (Basic Linear Algebra Subprograms) and LAPACK. R ships with a *reference* BLAS, which is reliable and portable but not optimised for modern processors. Optimised implementations such as [OpenBLAS](https://www.openblas.net/), Intel's MKL, or Apple's Accelerate framework use multiple cores and processor-specific instructions, and can make matrix-heavy code many times faster without you changing a single line of R.

You can check which BLAS your R is using with:

```r
sessionInfo()            # see the "BLAS:" and "LAPACK:" lines
extSoftVersion()["BLAS"]
```

A quick way to see the difference is to time a large matrix multiplication before and
after switching:

```r
m <- matrix(rnorm(2000 * 2000), 2000)
system.time(m %*% m)
```

On a 2025 MacBook Pro with an M5 chip, the above calculation took 1.82 seconds with the default BLAS library, and 0.038 after switching to the Accelerate framework, an almost 50x speed-up. 

How you switch depends on your operating system:

::::::::::::::::: tab

### Mac

* **macOS:** the CRAN installer includes a BLAS based on Apple's Accelerate (vecLib), but doesn't use it by default. To switch it on, run in the Terminal:

```bash
cd /Library/Frameworks/R.framework/Resources/lib
ln -sf libRblas.vecLib.dylib libRblas.dylib     # use Accelerate
# ln -sf libRblas.0.dylib libRblas.dylib        # switch back to R's reference BLAS
```

### Linux

* **Linux (Debian/Ubuntu):** R from the distribution uses the system BLAS, so you can
  install OpenBLAS and switch between implementations without reinstalling R:

```bash
sudo apt install libopenblas0-pthread
sudo update-alternatives --config libblas.so.3-x86_64-linux-gnu
```

Restart R and check `sessionInfo()`.

### Windows

* **Windows:** there's no built-in switch. Advanced users can replace `Rblas.dll` and
  `Rlapack.dll` in R's `bin\x64` folder with an OpenBLAS build. Keep a backup of the
  originals.


:::::::


Some cautions:

* Results may differ in the last few decimal places between BLAS implementations, because they order floating-point operations differently.
* Optimised BLAS libraries are usually multi-threaded. If you're *also* parallelising in R (e.g. with `parallel` or `future`), the two can compete for cores and slow each other down. The [RhpcBLASctl](https://cran.r-project.org/package=RhpcBLASctl) package lets you limit BLAS threads, e.g. `RhpcBLASctl::blas_set_num_threads(1)`.
* A faster BLAS only helps code that spends its time in linear algebra. It won't speed up loops, data manipulation or string processing.

For full details, see the [BLAS section of the *R Installation and Administration*
manual](https://cran.r-project.org/doc/manuals/r-release/R-admin.html#BLAS).

::::::::::::::::::::::::::::::::::::: keypoints 

- Keep your R version and R packages up-to-date
- Look for existing packages which already implement solutions to the bottlenecks you face
- Switch your BLAS library if your bottleneck is in linear algebra

::::::::::::::::::::::::::::::::::::::::::::::::


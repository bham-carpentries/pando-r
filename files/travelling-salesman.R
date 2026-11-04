# Naive brute force travelling salesman
#
# Interactively (e.g. for profiling with profvis):
#   source("travelling-salesman.R")
#   profvis::profvis(main(8))

distance <- function(point1, point2) {
  sqrt((point2[1] - point1[1])^2 + (point2[2] - point1[2])^2)
}

total_distance <- function(points, order) {
  total <- 0
  for (i in seq_len(length(order) - 1)) {
    total <- total + distance(points[[order[i]]], points[[order[i + 1]]])
  }
  total + distance(points[[order[length(order)]]], points[[order[1]]])
}

# Returns the next permutation of `order` in lexicographic order,
# or NULL once the last permutation has been reached.
next_permutation <- function(order) {
  n <- length(order)
  i <- n - 1
  while (i >= 1 && order[i] >= order[i + 1]) {
    i <- i - 1
  }
  if (i < 1) {
    return(NULL)
  }
  j <- n
  while (order[j] <= order[i]) {
    j <- j - 1
  }
  tmp <- order[i]
  order[i] <- order[j]
  order[j] <- tmp
  order[(i + 1):n] <- rev(order[(i + 1):n])
  order
}

travelling_salesman_brute_force <- function(points) {
  min_distance <- Inf
  min_path <- NULL
  order <- seq_along(points)
  while (!is.null(order)) {
    d <- total_distance(points, order)
    if (d < min_distance) {
      min_distance <- d
      min_path <- order
    }
    order <- next_permutation(order)
  }
  list(path = min_path, distance = min_distance)
}

travelling_salesman <- function(n_cities) {
  # Define the cities as (x, y) coordinates
  set.seed(12) # For reproducibility/consistency
  cities <- list(c(0, 0))
  for (i in seq_len(n_cities)) {
    x <- runif(1, -1, 1)
    y <- runif(1, -1, 1)
    cities[[length(cities) + 1]] <- c(x, y)
  }

  # Find the shortest path
  start_time <- Sys.time()
  result <- travelling_salesman_brute_force(cities)
  end_time <- Sys.time()

  cat("Cities:", n_cities, "\n")
  cat(
    "Shortest Path:",
    paste0("(", paste(result$path, collapse = ", "), ")"),
    "\n"
  )
  cat("Shortest Distance:", format(result$distance, digits = 15), "\n")
  cat(sprintf(
    "Execution time: %.3f s\n",
    as.numeric(difftime(end_time, start_time, units = "secs"))
  ))
  invisible(result)
}

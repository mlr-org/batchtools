# Reduce Results

A version of [`Reduce`](https://rdrr.io/r/base/funprog.html) for
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)
objects which iterates over finished jobs and aggregates them. All jobs
must have terminated, an error is raised otherwise.

## Usage

``` r
reduceResults(fun, ids = NULL, init, ..., reg = getDefaultRegistry())
```

## Arguments

- fun:

  \[`function`\]  
  A function to reduce the results. The result of previous iterations
  (or the `init`) will be passed as first argument, the result of of the
  i-th iteration as second. See
  [`Reduce`](https://rdrr.io/r/base/funprog.html) for some examples. If
  the function has the formal argument “job”, the
  [`Job`](https://batchtools.mlr-org.com/reference/JobExperiment.md)/[`Experiment`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  is also passed to the function (named).

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to the return value
  of [`findDone`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- init:

  \[`ANY`\]  
  Initial element, as used in
  [`Reduce`](https://rdrr.io/r/base/funprog.html). If missing, the
  reduction uses the result of the first job as `init` and the reduction
  starts with the second job.

- ...:

  \[`ANY`\]  
  Additional arguments passed to function `fun`.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

Aggregated results in the same order as provided ids. Return type
depends on the user function. If `ids` is empty, `reduceResults` returns
`init` (if available) or `NULL` otherwise.

## Note

If you have thousands of jobs, disabling the progress bar
(`options(batchtools.progress = FALSE)`) can significantly increase the
performance.

## See also

Other Results:
[`batchMapResults()`](https://batchtools.mlr-org.com/reference/batchMapResults.md),
[`loadResult()`](https://batchtools.mlr-org.com/reference/loadResult.md),
[`reduceResultsList()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(function(a, b) list(sum = a+b, prod = a*b), a = 1:3, b = 1:3, reg = tmp)
#> Adding 3 jobs ...
submitJobs(reg = tmp)
#> Submitting 3 jobs in 3 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE

# Extract element sum from each result
reduceResults(function(aggr, res) c(aggr, res$sum), init = list(), reg = tmp)
#> [[1]]
#> [1] 2
#> 
#> [[2]]
#> [1] 4
#> 
#> [[3]]
#> [1] 6
#> 

# Aggregate element sum via '+'
reduceResults(function(aggr, res) aggr + res$sum, init = 0, reg = tmp)
#> [1] 12

# Aggregate element prod via '*' where parameter b < 3
reduce = function(aggr, res, job) {
  if (job$pars$b >= 3)
    return(aggr)
  aggr * res$prod
}
reduceResults(reduce, init = 1, reg = tmp)
#> [1] 4

# Reduce to data.frame() (inefficient, use reduceResultsDataTable() instead)
reduceResults(rbind, init = data.frame(), reg = tmp)
#>   sum prod
#> 1   2    1
#> 2   4    4
#> 3   6    9

# Reduce to data.frame by collecting results first, then utilize vectorization of rbind:
res = reduceResultsList(fun = as.data.frame, reg = tmp)
do.call(rbind, res)
#>   sum prod
#> 1   2    1
#> 2   4    4
#> 3   6    9

# Reduce with custom combine function:
comb = function(x, y) list(sum = x$sum + y$sum, prod = x$prod * y$prod)
reduceResults(comb, reg = tmp)
#> $sum
#> [1] 12
#> 
#> $prod
#> [1] 36
#> 

# The same with neutral element NULL
comb = function(x, y) if (is.null(x)) y else list(sum = x$sum + y$sum, prod = x$prod * y$prod)
reduceResults(comb, init = NULL, reg = tmp)
#> $sum
#> [1] 12
#> 
#> $prod
#> [1] 36
#> 

# Alternative: Reduce in list, reduce manually in a 2nd step
res = reduceResultsList(reg = tmp)
Reduce(comb, res)
#> $sum
#> [1] 12
#> 
#> $prod
#> [1] 36
#> 
```

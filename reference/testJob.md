# Run Jobs Interactively

Starts a single job on the local machine.

## Usage

``` r
testJob(id, external = FALSE, reg = getDefaultRegistry())
```

## Arguments

- id:

  \[`integer(1)` or `data.table`\]  
  Single integer to specify the job or a `data.table` with column
  `job.id` and exactly one row.

- external:

  \[`logical(1)`\]  
  Run the job in an external R session? If `TRUE`, starts a fresh R
  session on the local machine to execute the with
  [`execJob`](https://batchtools.mlr-org.com/reference/execJob.md). You
  will not be able to use debug tools like
  [`traceback`](https://rdrr.io/r/base/traceback.html) or
  [`browser`](https://rdrr.io/r/base/browser.html).

  If `external` is set to `FALSE` (default) on the other hand, `testJob`
  will execute the job in the current R session and the usual debugging
  tools work. However, spotting missing variable declarations (as they
  are possibly resolved in the global environment) is impossible. Same
  holds for missing package dependency declarations.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

Returns the result of the job if successful.

## See also

Other debug:
[`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md),
[`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md),
[`grepLogs()`](https://batchtools.mlr-org.com/reference/grepLogs.md),
[`killJobs()`](https://batchtools.mlr-org.com/reference/killJobs.md),
[`resetJobs()`](https://batchtools.mlr-org.com/reference/resetJobs.md),
[`showLog()`](https://batchtools.mlr-org.com/reference/showLog.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(function(x) if (x == 2) xxx else x, 1:2, reg = tmp)
#> Adding 2 jobs ...
testJob(1, reg = tmp)
#> ### [bt]: Setting seed to 13900 ...
#> [1] 1
if (FALSE) { # \dontrun{
testJob(2, reg = tmp)
} # }
```

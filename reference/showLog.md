# Inspect Log Files

`showLog` opens the log in the pager. For customization, see
[`file.show`](https://rdrr.io/r/base/file.show.html). `getLog` returns
the log as character vector.

## Usage

``` r
showLog(id, reg = getDefaultRegistry())

getLog(id, reg = getDefaultRegistry())
```

## Arguments

- id:

  \[`integer(1)` or `data.table`\]  
  Single integer to specify the job or a `data.table` with column
  `job.id` and exactly one row.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

Nothing.

## See also

Other debug:
[`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md),
[`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md),
[`grepLogs()`](https://batchtools.mlr-org.com/reference/grepLogs.md),
[`killJobs()`](https://batchtools.mlr-org.com/reference/killJobs.md),
[`resetJobs()`](https://batchtools.mlr-org.com/reference/resetJobs.md),
[`testJob()`](https://batchtools.mlr-org.com/reference/testJob.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'

# Create some dummy jobs
fun = function(i) {
  if (i == 3) stop(i)
  if (i %% 2 == 1) warning("That's odd.")
}
ids = batchMap(fun, i = 1:5, reg = tmp)
#> Adding 5 jobs ...
submitJobs(reg = tmp)
#> Submitting 5 jobs in 5 chunks using cluster functions 'Interactive' ...
#> Warning: That's odd.
#> Error in (function (i)  : 3
#> Warning: That's odd.
waitForJobs(reg = tmp)
#> [1] FALSE
getStatus(reg = tmp)
#> Status for 5 jobs at 2025-11-26 10:23:39:
#>   Submitted    : 5 (100.0%)
#>   -- Queued    : 0 (  0.0%)
#>   -- Started   : 5 (100.0%)
#>   ---- Running : 0 (  0.0%)
#>   ---- Done    : 4 ( 80.0%)
#>   ---- Error   : 1 ( 20.0%)
#>   ---- Expired : 0 (  0.0%)

writeLines(getLog(ids[1], reg = tmp))
#> ### [bt]: This is batchtools v0.9.18
#> ### [bt]: Starting calculation of 1 jobs
#> ### [bt]: Setting working directory to '/home/runner/work/batchtools/batchtools/docs/reference'
#> ### [bt]: Memory measurement disabled
#> ### [bt]: Starting job [batchtools job.id=1]
#> ### [bt]: Setting seed to 15724 ...
#> 
#> ### [bt]: Job terminated successfully [batchtools job.id=1]
#> ### [bt]: Calculation finished!
if (FALSE) { # \dontrun{
showLog(ids[1], reg = tmp)
} # }

grepLogs(pattern = "warning", ignore.case = TRUE, reg = tmp)
#> Key: <job.id>
#> Empty data.table (0 rows and 2 cols): job.id,matches
```

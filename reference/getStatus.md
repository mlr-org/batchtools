# Summarize the Computational Status

This function gives an encompassing overview over the computational
status on your system. The status can be one or many of the following:

- “defined”: Jobs which are defined via
  [`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md) or
  [`addExperiments`](https://batchtools.mlr-org.com/reference/addExperiments.md),
  but are not yet submitted.

- “submitted”: Jobs which are submitted to the batch system via
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md),
  scheduled for execution.

- “started”: Jobs which have been started.

- “done”: Jobs which terminated successfully.

- “error”: Jobs which terminated with an exception.

- “running”: Jobs which are listed by the cluster functions to be
  running on the live system. Not supported for all cluster functions.

- “queued”: Jobs which are listed by the cluster functions to be queued
  on the live system. Not supported for all cluster functions.

- “system”: Jobs which are listed by the cluster functions to be queued
  or running. Not supported for all cluster functions.

- “expired”: Jobs which have been submitted, but vanished from the live
  system. Note that this is determined heuristically and may include
  some false positives.

Here, a job which terminated successfully counts towards the jobs which
are submitted, started and done. To retrieve the corresponding job ids,
see [`findJobs`](https://batchtools.mlr-org.com/reference/findJobs.md).

## Usage

``` r
getStatus(ids = NULL, reg = getDefaultRegistry())
```

## Arguments

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to all jobs.
  Invalid ids are ignored.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
(with class “Status” for printing).

## See also

[`findJobs`](https://batchtools.mlr-org.com/reference/findJobs.md)

Other debug:
[`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md),
[`grepLogs()`](https://batchtools.mlr-org.com/reference/grepLogs.md),
[`killJobs()`](https://batchtools.mlr-org.com/reference/killJobs.md),
[`resetJobs()`](https://batchtools.mlr-org.com/reference/resetJobs.md),
[`showLog()`](https://batchtools.mlr-org.com/reference/showLog.md),
[`testJob()`](https://batchtools.mlr-org.com/reference/testJob.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
fun = function(i) if (i == 3) stop(i) else i
ids = batchMap(fun, i = 1:5, reg = tmp)
#> Adding 5 jobs ...
submitJobs(ids = 1:4, reg = tmp)
#> Submitting 4 jobs in 4 chunks using cluster functions 'Interactive' ...
#> Error in (function (i)  : 3
waitForJobs(reg = tmp)
#> [1] FALSE

tab = getStatus(reg = tmp)
print(tab)
#> Status for 5 jobs at 2025-11-26 10:22:55:
#>   Submitted    : 4 ( 80.0%)
#>   -- Queued    : 0 (  0.0%)
#>   -- Started   : 4 ( 80.0%)
#>   ---- Running : 0 (  0.0%)
#>   ---- Done    : 3 ( 60.0%)
#>   ---- Error   : 1 ( 20.0%)
#>   ---- Expired : 0 (  0.0%)
str(tab)
#> Classes ‘Status’, ‘data.table’ and 'data.frame': 1 obs. of  9 variables:
#>  $ defined  : int 5
#>  $ submitted: int 4
#>  $ started  : int 4
#>  $ done     : int 3
#>  $ error    : int 1
#>  $ queued   : int 0
#>  $ running  : int 0
#>  $ expired  : int 0
#>  $ system   : int 0
#>  - attr(*, ".internal.selfref")=<externalptr> 
```

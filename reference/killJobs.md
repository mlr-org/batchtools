# Kill Jobs

Kill jobs which are currently running on the batch system.

In case of an error when killing, the function tries - after a short
sleep - to kill the remaining batch jobs again. If this fails three
times for some jobs, the function gives up. Jobs that could be
successfully killed are reset in the
[Registry](https://batchtools.mlr-org.com/reference/makeRegistry.md).

## Usage

``` r
killJobs(ids = NULL, reg = getDefaultRegistry())
```

## Arguments

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to the return value
  of
  [`findOnSystem`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with columns “job.id”, the corresponding “batch.id” and the logical flag
“killed” indicating success.

## See also

Other debug:
[`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md),
[`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md),
[`grepLogs()`](https://batchtools.mlr-org.com/reference/grepLogs.md),
[`resetJobs()`](https://batchtools.mlr-org.com/reference/resetJobs.md),
[`showLog()`](https://batchtools.mlr-org.com/reference/showLog.md),
[`testJob()`](https://batchtools.mlr-org.com/reference/testJob.md)

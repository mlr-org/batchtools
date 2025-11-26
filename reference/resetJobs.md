# Reset the Computational State of Jobs

Resets the computational state of jobs in the
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md).
This function automatically checks if any of the jobs to reset is either
pending or running. However, if the implemented heuristic fails, this
can lead to inconsistencies in the data base. Use with care while jobs
are running.

## Usage

``` r
resetJobs(ids = NULL, reg = getDefaultRegistry())
```

## Arguments

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to no job. Invalid
  ids are ignored.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
of job ids which have been reset. See
[`JoinTables`](https://batchtools.mlr-org.com/reference/JoinTables.md)
for examples on working with job tables.

## See also

Other debug:
[`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md),
[`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md),
[`grepLogs()`](https://batchtools.mlr-org.com/reference/grepLogs.md),
[`killJobs()`](https://batchtools.mlr-org.com/reference/killJobs.md),
[`showLog()`](https://batchtools.mlr-org.com/reference/showLog.md),
[`testJob()`](https://batchtools.mlr-org.com/reference/testJob.md)

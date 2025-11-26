# Grep Log Files for a Pattern

Crawls through log files and reports jobs with lines matching the
`pattern`. See
[`showLog`](https://batchtools.mlr-org.com/reference/showLog.md) for an
example.

## Usage

``` r
grepLogs(
  ids = NULL,
  pattern,
  ignore.case = FALSE,
  fixed = FALSE,
  reg = getDefaultRegistry()
)
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
  [`findStarted`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- pattern:

  \[`character(1L)`\]  
  Regular expression or string (see `fixed`).

- ignore.case:

  \[`logical(1L)`\]  
  If `TRUE` the match will be performed case insensitively.

- fixed:

  \[`logical(1L)`\]  
  If `FALSE` (default), `pattern` is a regular expression and a fixed
  string otherwise.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with columns “job.id” and “message”.

## See also

Other debug:
[`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md),
[`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md),
[`killJobs()`](https://batchtools.mlr-org.com/reference/killJobs.md),
[`resetJobs()`](https://batchtools.mlr-org.com/reference/resetJobs.md),
[`showLog()`](https://batchtools.mlr-org.com/reference/showLog.md),
[`testJob()`](https://batchtools.mlr-org.com/reference/testJob.md)

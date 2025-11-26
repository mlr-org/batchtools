# Retrieve Error Messages

Extracts error messages from the internal data base and returns them in
a table.

## Usage

``` r
getErrorMessages(
  ids = NULL,
  missing.as.error = FALSE,
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
  [`findErrors`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- missing.as.error:

  \[`logical(1)`\]  
  Treat missing results as errors? If `TRUE`, the error message “\[not
  terminated\]” is imputed for jobs which have not terminated. Default
  is `FALSE`

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with columns “job.id”, “terminated” (logical), “error” (logical) and
“message” (string).

## See also

Other debug:
[`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md),
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
submitJobs(1:4, reg = tmp)
#> Submitting 4 jobs in 4 chunks using cluster functions 'Interactive' ...
#> Error in (function (i)  : 3
waitForJobs(1:4, reg = tmp)
#> [1] FALSE
getErrorMessages(ids, reg = tmp)
#> Key: <job.id>
#>    job.id terminated  error                     message
#>     <int>     <lgcl> <lgcl>                      <char>
#> 1:      1       TRUE  FALSE                        <NA>
#> 2:      2       TRUE  FALSE                        <NA>
#> 3:      3       TRUE   TRUE Error in (function (i)  : 3
#> 4:      4       TRUE  FALSE                        <NA>
#> 5:      5      FALSE  FALSE                        <NA>
getErrorMessages(ids, missing.as.error = TRUE, reg = tmp)
#> Key: <job.id>
#>    job.id terminated  error                     message
#>     <int>     <lgcl> <lgcl>                      <char>
#> 1:      1       TRUE  FALSE                        <NA>
#> 2:      2       TRUE  FALSE                        <NA>
#> 3:      3       TRUE   TRUE Error in (function (i)  : 3
#> 4:      4       TRUE  FALSE                        <NA>
#> 5:      5      FALSE   TRUE            [not terminated]
```

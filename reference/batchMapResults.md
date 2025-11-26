# Map Over Results to Create New Jobs

This function allows you to create new computational jobs (just like
[`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md) based
on the results of a
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md).

## Usage

``` r
batchMapResults(
  fun,
  ids = NULL,
  ...,
  more.args = list(),
  target,
  source = getDefaultRegistry()
)
```

## Arguments

- fun:

  \[`function`\]  
  Function which takes the result as first (unnamed) argument.

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to the return value
  of [`findDone`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- ...:

  \[ANY\]  
  Arguments to vectorize over (list or vector). Passed to
  [`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md).

- more.args:

  \[`list`\]  
  A list of further arguments passed to `fun`. Default is an empty list.

- target:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Empty Registry where new jobs are created for.

- source:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with ids of jobs added to `target`.

## Note

The URI to the result files in registry `source` is hard coded as
parameter in the `target` registry. This means that `target` is
currently not portable between systems for computation.

## See also

Other Results:
[`loadResult()`](https://batchtools.mlr-org.com/reference/loadResult.md),
[`reduceResults()`](https://batchtools.mlr-org.com/reference/reduceResults.md),
[`reduceResultsList()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)

## Examples

``` r
# Source registry: calculate square of some numbers
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg1' using cluster functions 'Interactive'
batchMap(function(x) list(square = x^2), x = 1:10, reg = tmp)
#> Adding 10 jobs ...
submitJobs(reg = tmp)
#> Submitting 10 jobs in 10 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE

# Target registry: calculate the square root on results of first registry
target = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg2' using cluster functions 'Interactive'
batchMapResults(fun = function(x, y) list(sqrt = sqrt(x$square)), ids = 4:8,
  target = target, source = tmp)
#> Adding 5 jobs ...
submitJobs(reg = target)
#> Submitting 5 jobs in 5 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = target)
#> [1] TRUE

# Map old to new ids. First, get a table with results and parameters
results = unwrap(rjoin(getJobPars(reg = target), reduceResultsDataTable(reg = target)))
print(results)
#> Key: <job.id>
#>    job.id   .id  sqrt
#>     <int> <int> <num>
#> 1:      1     4     4
#> 2:      2     5     5
#> 3:      3     6     6
#> 4:      4     7     7
#> 5:      5     8     8

# Parameter '.id' points to job.id in 'source'. Use a inner join to combine:
ijoin(results, unwrap(reduceResultsDataTable(reg = tmp)), by = c(".id" = "job.id"))
#> Key: <.id>
#>    job.id   .id  sqrt square
#>     <int> <int> <num>  <num>
#> 1:      1     4     4     16
#> 2:      2     5     5     25
#> 3:      3     6     6     36
#> 4:      4     7     7     49
#> 5:      5     8     8     64
```

# Map Operation for Batch Systems

A parallel and asynchronous
[`Map`](https://rdrr.io/r/base/funprog.html)/[`mapply`](https://rdrr.io/r/base/mapply.html)
for batch systems. Note that this function only defines the
computational jobs. The actual computation is started with
[`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).
Results and partial results can be collected with
[`reduceResultsList`](https://batchtools.mlr-org.com/reference/reduceResultsList.md),
[`reduceResults`](https://batchtools.mlr-org.com/reference/reduceResults.md)
or
[`loadResult`](https://batchtools.mlr-org.com/reference/loadResult.md).

For a synchronous [`Map`](https://rdrr.io/r/base/funprog.html)-like
execution, see
[`btmapply`](https://batchtools.mlr-org.com/reference/btlapply.md).

## Usage

``` r
batchMap(
  fun,
  ...,
  args = list(),
  more.args = list(),
  reg = getDefaultRegistry()
)
```

## Arguments

- fun:

  \[`function`\]  
  Function to map over arguments provided via `...`. Parameters given
  via `args` or `...` are passed as-is, in the respective order and
  possibly named. If the function has the named formal argument “.job”,
  the [`Job`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  is passed to the function on the slave.

- ...:

  \[ANY\]  
  Arguments to vectorize over (list or vector). Shorter vectors will be
  recycled (possibly with a warning any length is not a multiple of the
  longest length). Mutually exclusive with `args`. Note that although it
  is possible to iterate over large objects (e.g., lists of data frames
  or matrices), this usually hurts the overall performance and thus is
  discouraged.

- args:

  \[`list` \| `data.frame`\]  
  Arguments to vectorize over as (named) list or data frame. Shorter
  vectors will be recycled (possibly with a warning any length is not a
  multiple of the longest length). Mutually exclusive with `...`.

- more.args:

  \[`list`\]  
  A list of further arguments passed to `fun`. Default is an empty list.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with ids of added jobs stored in column “job.id”.

## See also

[`batchReduce`](https://batchtools.mlr-org.com/reference/batchReduce.md)

## Examples

``` r
# example using "..." and more.args
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg1' using cluster functions 'Interactive'
f = function(x, y) x^2 + y
ids = batchMap(f, x = 1:10, more.args = list(y = 100), reg = tmp)
#> Adding 10 jobs ...
getJobPars(reg = tmp)
#> Key: <job.id>
#>     job.id  job.pars
#>      <int>    <list>
#>  1:      1 <list[1]>
#>  2:      2 <list[1]>
#>  3:      3 <list[1]>
#>  4:      4 <list[1]>
#>  5:      5 <list[1]>
#>  6:      6 <list[1]>
#>  7:      7 <list[1]>
#>  8:      8 <list[1]>
#>  9:      9 <list[1]>
#> 10:     10 <list[1]>
testJob(6, reg = tmp) # 100 + 6^2 = 136
#> ### [bt]: Setting seed to 23542 ...
#> [1] 136

# vector recycling
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg2' using cluster functions 'Interactive'
f = function(...) list(...)
ids = batchMap(f, x = 1:3, y = 1:6, reg = tmp)
#> Adding 6 jobs ...
getJobPars(reg = tmp)
#> Key: <job.id>
#>    job.id  job.pars
#>     <int>    <list>
#> 1:      1 <list[2]>
#> 2:      2 <list[2]>
#> 3:      3 <list[2]>
#> 4:      4 <list[2]>
#> 5:      5 <list[2]>
#> 6:      6 <list[2]>

# example for an expand.grid()-like operation on parameters
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg3' using cluster functions 'Interactive'
ids = batchMap(paste, args = data.table::CJ(x = letters[1:3], y = 1:3), reg = tmp)
#> Adding 9 jobs ...
getJobPars(reg = tmp)
#> Key: <job.id>
#>    job.id  job.pars
#>     <int>    <list>
#> 1:      1 <list[2]>
#> 2:      2 <list[2]>
#> 3:      3 <list[2]>
#> 4:      4 <list[2]>
#> 5:      5 <list[2]>
#> 6:      6 <list[2]>
#> 7:      7 <list[2]>
#> 8:      8 <list[2]>
#> 9:      9 <list[2]>
testJob(6, reg = tmp)
#> ### [bt]: Setting seed to 13241 ...
#> [1] "b 3"
```

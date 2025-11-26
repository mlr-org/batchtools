# Reduce Operation for Batch Systems

A parallel and asynchronous
[`Reduce`](https://rdrr.io/r/base/funprog.html) for batch systems. Note
that this function only defines the computational jobs. Each job reduces
a certain number of elements on one slave. The actual computation is
started with
[`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).
Results and partial results can be collected with
[`reduceResultsList`](https://batchtools.mlr-org.com/reference/reduceResultsList.md),
[`reduceResults`](https://batchtools.mlr-org.com/reference/reduceResults.md)
or
[`loadResult`](https://batchtools.mlr-org.com/reference/loadResult.md).

## Usage

``` r
batchReduce(
  fun,
  xs,
  init = NULL,
  chunks = seq_along(xs),
  more.args = list(),
  reg = getDefaultRegistry()
)
```

## Arguments

- fun:

  \[`function(aggr, x, ...)`\]  
  Function to reduce `xs` with.

- xs:

  \[`vector`\]  
  Vector to reduce.

- init:

  \[ANY\]  
  Initial object for reducing. See
  [`Reduce`](https://rdrr.io/r/base/funprog.html).

- chunks:

  \[`integer(length(xs))`\]  
  Group for each element of `xs`. Can be generated with
  [`chunk`](https://batchtools.mlr-org.com/reference/chunk.md).

- more.args:

  \[`list`\]  
  A list of additional arguments passed to `fun`.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with ids of added jobs stored in column “job.id”.

## See also

[`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md)

## Examples

``` r
# define function to reduce on slave, we want to sum a vector
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
xs = 1:100
f = function(aggr, x) aggr + x

# sum 20 numbers on each slave process, i.e. 5 jobs
chunks = chunk(xs, chunk.size = 5)
batchReduce(fun = f, 1:100, init = 0, chunks = chunks, reg = tmp)
#> Adding 20 jobs ...
submitJobs(reg = tmp)
#> Submitting 20 jobs in 20 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE

# now reduce one final time on master
reduceResults(fun = function(aggr, job, res) f(aggr, res), reg = tmp)
#> [1] 5050
```

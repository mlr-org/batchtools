# Synchronous Apply Functions

This is a set of functions acting as counterparts to the sequential
popular apply functions in base R: `btlapply` for
[`lapply`](https://rdrr.io/r/base/lapply.html) and `btmapply` for
[`mapply`](https://rdrr.io/r/base/mapply.html).

Internally, jobs are created using
[`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md) on
the provided registry. If no registry is provided, a temporary registry
(see argument `file.dir` of
[`makeRegistry`](https://batchtools.mlr-org.com/reference/makeRegistry.md))
and [`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md)
will be used. After all jobs are terminated (see
[`waitForJobs`](https://batchtools.mlr-org.com/reference/waitForJobs.md)),
the results are collected and returned as a list.

Note that these functions are only suitable for short and fail-safe
operations on batch system. If some jobs fail, you have to retrieve
partial results from the registry directory yourself.

## Usage

``` r
btlapply(
  X,
  fun,
  ...,
  resources = list(),
  n.chunks = NULL,
  chunk.size = NULL,
  reg = makeRegistry(file.dir = NA)
)

btmapply(
  fun,
  ...,
  more.args = list(),
  simplify = FALSE,
  use.names = TRUE,
  resources = list(),
  n.chunks = NULL,
  chunk.size = NULL,
  reg = makeRegistry(file.dir = NA)
)
```

## Arguments

- X:

  \[[`vector`](https://rdrr.io/r/base/vector.html)\]  
  Vector to apply over.

- fun:

  \[`function`\]  
  Function to apply.

- ...:

  \[`ANY`\]  
  Additional arguments passed to `fun` (`btlapply`) or vectors to map
  over (`btmapply`).

- resources:

  \[`named list`\]  
  Computational resources for the jobs to submit. The actual elements of
  this list (e.g. something like “walltime” or “nodes”) depend on your
  template file, exceptions are outlined in the section 'Resources'.
  Default settings for a system can be set in the configuration file by
  defining the named list `default.resources`. Note that these settings
  are merged by name, e.g. merging `list(walltime = 300)` into
  `list(walltime = 400, memory = 512)` will result in
  `list(walltime = 300, memory = 512)`. Same holds for individual job
  resources passed as additional column of `ids` (c.f. section
  'Resources').

- n.chunks:

  \[`integer(1)`\]  
  Passed to [`chunk`](https://batchtools.mlr-org.com/reference/chunk.md)
  before
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).

- chunk.size:

  \[`integer(1)`\]  
  Passed to [`chunk`](https://batchtools.mlr-org.com/reference/chunk.md)
  before
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

- more.args:

  \[`list`\]  
  Additional arguments passed to `fun`.

- simplify:

  \[`logical(1)`\]  
  Simplify the results using
  [`simplify2array`](https://rdrr.io/r/base/lapply.html)?

- use.names:

  \[`logical(1)`\]  
  Use names of the input to name the output?

## Value

\[`list`\] List with the results of the function call.

## Examples

``` r
btlapply(1:3, function(x) x^2)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
#> Adding 3 jobs ...
#> Submitting 3 jobs in 3 chunks using cluster functions 'Interactive' ...
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 4
#> 
#> [[3]]
#> [1] 9
#> 
btmapply(function(x, y, z) x + y + z, x = 1:3, y = 1:3, more.args = list(z = 1), simplify = TRUE)
#> No readable configuration file found
#> Created registry in '/tmp/RtmprPuY0L/registry263978bc7610' using cluster functions 'Interactive'
#> Adding 3 jobs ...
#> Submitting 3 jobs in 3 chunks using cluster functions 'Interactive' ...
#> [1] 3 5 7
```

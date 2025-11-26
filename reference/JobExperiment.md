# Jobs and Experiments

Jobs and Experiments are abstract objects which hold all information
necessary to execute a single computational job for a
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)
or
[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md),
respectively.

They can be created using the constructor `makeJob` which takes a single
job id. Jobs and Experiments are passed to reduce functions like
[`reduceResults`](https://batchtools.mlr-org.com/reference/reduceResults.md).
Furthermore, Experiments can be used in the functions of the
[`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md) and
[`Algorithm`](https://batchtools.mlr-org.com/reference/addAlgorithm.md).
Jobs and Experiments hold these information:

- `job.id`:

  Job ID as integer.

- `pars`:

  Job parameters as named list. For
  [`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md),
  the parameters are divided into the sublists “prob.pars” and
  “algo.pars”.

- `seed`:

  Seed which is set via
  [`doJobCollection`](https://batchtools.mlr-org.com/reference/doJobCollection.md)
  as scalar integer.

- `resources`:

  Computational resources which were set for this job as named list.

- `external.dir`:

  Path to a directory which is created exclusively for this job. You can
  store external files here. Directory is persistent between multiple
  restarts of the job and can be cleaned by calling
  [`resetJobs`](https://batchtools.mlr-org.com/reference/resetJobs.md).

- `fun`:

  Job only: User function passed to
  [`batchMap`](https://batchtools.mlr-org.com/reference/batchMap.md).

- `prob.name`:

  Experiments only: Problem id.

- `algo.name`:

  Experiments only: Algorithm id.

- `problem`:

  Experiments only:
  [`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md).

- `instance`:

  Experiments only: Problem instance.

- `algorithm`:

  Experiments only:
  [`Algorithm`](https://batchtools.mlr-org.com/reference/addAlgorithm.md).

- `repl`:

  Experiments only: Replication number.

Note that the slots “pars”, “fun”, “algorithm” and “problem” lazy-load
required files from the file system and construct the object on the
first access. The realizations are cached for all slots except
“instance” (which might be stochastic).

Jobs and Experiments can be executed manually with
[`execJob`](https://batchtools.mlr-org.com/reference/execJob.md).

## Usage

``` r
makeJob(id, reader = NULL, reg = getDefaultRegistry())
```

## Arguments

- id:

  \[`integer(1)` or `data.table`\]  
  Single integer to specify the job or a `data.table` with column
  `job.id` and exactly one row.

- reader:

  \[`RDSReader` \| `NULL`\]  
  Reader object to retrieve files. Used internally to cache reading from
  the file system. The default (`NULL`) does not make use of caching.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`Job` \| `Experiment`\].

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(function(x, y) x + y, x = 1:2, more.args = list(y = 99), reg = tmp)
#> Adding 2 jobs ...
submitJobs(resources = list(foo = "bar"), reg = tmp)
#> Submitting 2 jobs in 2 chunks using cluster functions 'Interactive' ...
job = makeJob(1, reg = tmp)
print(job)
#> <Job>
#>   Inherits from: <BaseJob>
#>   Public:
#>     external.dir: active binding
#>     file.dir: /tmp/batchtools-example/reg
#>     fun: active binding
#>     id: 1
#>     initialize: function (file.dir, reader, id, job.pars, seed, resources) 
#>     job.id: active binding
#>     job.pars: list
#>     pars: active binding
#>     reader: RDSReader, R6
#>     resources: list
#>     seed: 25315

# Get the parameters:
job$pars
#> $x
#> [1] 1
#> 
#> $y
#> [1] 99
#> 

# Get the job resources:
job$resources
#> $foo
#> [1] "bar"
#> 

# Execute the job locally:
execJob(job)
#> ### [bt]: Setting seed to 25315 ...
#> [1] 100
```

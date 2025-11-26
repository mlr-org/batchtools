# Define Problems for Experiments

Problems may consist of up to two parts: A static, immutable part
(`data` in `addProblem`) and a dynamic, stochastic part (`fun` in
`addProblem`). For example, for statistical learning problems a data
frame would be the static problem part while a resampling function would
be the stochastic part which creates problem instance. This instance is
then typically passed to a learning algorithm like a wrapper around a
statistical model (`fun` in
[`addAlgorithm`](https://batchtools.mlr-org.com/reference/addAlgorithm.md)).

This function serialize all components to the file system and registers
the problem in the
[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md).

`removeProblem` removes all jobs from the registry which depend on the
specific problem. `reg$problems` holds the IDs of already defined
problems.

## Usage

``` r
addProblem(
  name,
  data = NULL,
  fun = NULL,
  seed = NULL,
  cache = FALSE,
  reg = getDefaultRegistry()
)

removeProblems(name, reg = getDefaultRegistry())
```

## Arguments

- name:

  \[`character(1)`\]  
  Unique identifier for the problem.

- data:

  \[`ANY`\]  
  Static problem part. Default is `NULL`.

- fun:

  \[`function`\]  
  The function defining the stochastic problem part. The static part is
  passed to this function with name “data” and the
  [`Job`](https://batchtools.mlr-org.com/reference/JobExperiment.md)/[`Experiment`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  is passed as “job”. Therefore, your function must have the formal
  arguments “job” and “data” (or dots `...`). If you do not provide a
  function, it defaults to a function which just returns the data part.

- seed:

  \[`integer(1)`\]  
  Start seed for this problem. This allows the “synchronization” of a
  stochastic problem across algorithms, so that different algorithms are
  evaluated on the same stochastic instance. If the problem seed is
  defined, the seeding mechanism works as follows: (1) Before the
  dynamic part of a problem is instantiated, the seed of the problem +
  \[replication number\] - 1 is set, i.e. the first replication uses the
  problem seed. (2) The stochastic part of the problem is
  instantiated. (3) From now on the usual experiment seed of the
  registry is used, see
  [`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md).
  If `seed` is set to `NULL` (default), the job seed is used to
  instantiate the problem and different algorithms see different
  stochastic instances of the same problem.

- cache:

  \[`logical(1)`\]  
  If `TRUE` and `seed` is set, problem instances will be cached on the
  file system. This assumes that each problem instance is deterministic
  for each combination of hyperparameter setting and each replication
  number. This feature is experimental.

- reg:

  \[[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)\]  
  Registry. If not explicitly passed, uses the last created registry.

## Value

\[`Problem`\]. Object of class “Problem” (invisibly).

## See also

[`Algorithm`](https://batchtools.mlr-org.com/reference/addAlgorithm.md),
[`addExperiments`](https://batchtools.mlr-org.com/reference/addExperiments.md)

## Examples

``` r
tmp = makeExperimentRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
addProblem("p1", fun = function(job, data) data, reg = tmp)
#> Adding problem 'p1'
addProblem("p2", fun = function(job, data) job, reg = tmp)
#> Adding problem 'p2'
addAlgorithm("a1", fun = function(job, data, instance) instance, reg = tmp)
#> Adding algorithm 'a1'
addExperiments(repls = 2, reg = tmp)
#> Adding 2 experiments ('p1'[1] x 'a1'[1] x repls[2]) ...
#> Adding 2 experiments ('p2'[1] x 'a1'[1] x repls[2]) ...

# List problems, algorithms and job parameters:
tmp$problems
#> [1] "p1" "p2"
tmp$algorithms
#> [1] "a1"
getJobPars(reg = tmp)
#> Key: <job.id>
#>    job.id problem prob.pars algorithm algo.pars
#>     <int>  <char>    <list>    <char>    <list>
#> 1:      1      p1 <list[0]>        a1 <list[0]>
#> 2:      2      p1 <list[0]>        a1 <list[0]>
#> 3:      3      p2 <list[0]>        a1 <list[0]>
#> 4:      4      p2 <list[0]>        a1 <list[0]>

# Remove one problem
removeProblems("p1", reg = tmp)
#> Removing Problem 'p1' and 2 corresponding jobs ...

# List problems and algorithms:
tmp$problems
#> [1] "p2"
tmp$algorithms
#> [1] "a1"
getJobPars(reg = tmp)
#> Key: <job.id>
#>    job.id problem prob.pars algorithm algo.pars
#>     <int>  <char>    <list>    <char>    <list>
#> 1:      3      p2 <list[0]>        a1 <list[0]>
#> 2:      4      p2 <list[0]>        a1 <list[0]>
```

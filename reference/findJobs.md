# Find and Filter Jobs

These functions are used to find and filter jobs, depending on either
their parameters (`findJobs` and `findExperiments`), their tags
(`findTagged`), or their computational status (all other functions, see
[`getStatus`](https://batchtools.mlr-org.com/reference/getStatus.md) for
an overview).

Note that `findQueued`, `findRunning`, `findOnSystem` and `findExpired`
are somewhat heuristic and may report misleading results, depending on
the state of the system and the
[`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)
implementation.

See
[`JoinTables`](https://batchtools.mlr-org.com/reference/JoinTables.md)
for convenient set operations (unions, intersects, differences) on
tables with job ids.

## Usage

``` r
findJobs(expr, ids = NULL, reg = getDefaultRegistry())

findExperiments(
  ids = NULL,
  prob.name = NA_character_,
  prob.pattern = NA_character_,
  algo.name = NA_character_,
  algo.pattern = NA_character_,
  prob.pars,
  algo.pars,
  repls = NULL,
  reg = getDefaultRegistry()
)

findSubmitted(ids = NULL, reg = getDefaultRegistry())

findNotSubmitted(ids = NULL, reg = getDefaultRegistry())

findStarted(ids = NULL, reg = getDefaultRegistry())

findNotStarted(ids = NULL, reg = getDefaultRegistry())

findDone(ids = NULL, reg = getDefaultRegistry())

findNotDone(ids = NULL, reg = getDefaultRegistry())

findErrors(ids = NULL, reg = getDefaultRegistry())

findOnSystem(ids = NULL, reg = getDefaultRegistry())

findRunning(ids = NULL, reg = getDefaultRegistry())

findQueued(ids = NULL, reg = getDefaultRegistry())

findExpired(ids = NULL, reg = getDefaultRegistry())

findTagged(tags = character(0L), ids = NULL, reg = getDefaultRegistry())
```

## Arguments

- expr:

  \[`expression`\]  
  Predicate expression evaluated in the job parameters. Jobs for which
  `expr` evaluates to `TRUE` are returned.

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to all jobs.
  Invalid ids are ignored.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

- prob.name:

  \[`character`\]  
  Exact name of the problem (no substring matching). If not provided,
  all problems are matched.

- prob.pattern:

  \[`character`\]  
  Regular expression pattern to match problem names. If not provided,
  all problems are matched.

- algo.name:

  \[`character`\]  
  Exact name of the problem (no substring matching). If not provided,
  all algorithms are matched.

- algo.pattern:

  \[`character`\]  
  Regular expression pattern to match algorithm names. If not provided,
  all algorithms are matched.

- prob.pars:

  \[`expression`\]  
  Predicate expression evaluated in the problem parameters.

- algo.pars:

  \[`expression`\]  
  Predicate expression evaluated in the algorithm parameters.

- repls:

  \[`integer`\]  
  Whitelist of replication numbers. If not provided, all replications
  are matched.

- tags:

  \[`character`\]  
  Return jobs which are tagged with any of the tags provided.

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with column “job.id” containing matched jobs.

## See also

[`getStatus`](https://batchtools.mlr-org.com/reference/getStatus.md)
[`JoinTables`](https://batchtools.mlr-org.com/reference/JoinTables.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(identity, i = 1:3, reg = tmp)
#> Adding 3 jobs ...
ids = findNotSubmitted(reg = tmp)

# get all jobs:
findJobs(reg = tmp)
#> Key: <job.id>
#>    job.id
#>     <int>
#> 1:      1
#> 2:      2
#> 3:      3

# filter for jobs with parameter i >= 2
findJobs(i >= 2, reg = tmp)

# filter on the computational status
findSubmitted(reg = tmp)
#> Key: <job.id>
#> Empty data.table (0 rows and 1 cols): job.id
findNotDone(reg = tmp)
#> Key: <job.id>
#>    job.id
#>     <int>
#> 1:      1
#> 2:      2
#> 3:      3

# filter on tags
addJobTags(2:3, "my_tag", reg = tmp)
findTagged(tags = "my_tag", reg = tmp)
#> Key: <job.id>
#>    job.id
#>     <int>
#> 1:      2
#> 2:      3

# combine filter functions using joins
# -> jobs which are not done and not tagged (using an anti-join):
ajoin(findNotDone(reg = tmp), findTagged("my_tag", reg = tmp))
#> Key: <job.id>
#>    job.id
#>     <int>
#> 1:      1
```

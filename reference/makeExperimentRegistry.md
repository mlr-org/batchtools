# ExperimentRegistry Constructor

`makeExperimentRegistry` constructs a special
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)
which is suitable for the definition of large scale computer
experiments.

Each experiments consists of a
[`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md) and
an
[`Algorithm`](https://batchtools.mlr-org.com/reference/addAlgorithm.md).
These can be parametrized with
[`addExperiments`](https://batchtools.mlr-org.com/reference/addExperiments.md)
to actually define computational jobs.

## Usage

``` r
makeExperimentRegistry(
  file.dir = "registry",
  work.dir = getwd(),
  conf.file = findConfFile(),
  packages = character(0L),
  namespaces = character(0L),
  source = character(0L),
  load = character(0L),
  seed = NULL,
  make.default = TRUE
)
```

## Arguments

- file.dir:

  \[`character(1)`\]  
  Path where all files of the registry are saved. Default is directory
  “registry” in the current working directory. The provided path will
  get normalized unless it is given relative to the home directory
  (i.e., starting with “~”). Note that some templates do not handle
  relative paths well.

  If you pass `NA`, a temporary directory will be used. This way, you
  can create disposable registries for
  [`btlapply`](https://batchtools.mlr-org.com/reference/btlapply.md) or
  examples. By default, the temporary directory
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) will be used. If
  you want to use another directory, e.g. a directory which is shared
  between nodes, you can set it in your configuration file by setting
  the variable `temp.dir`.

- work.dir:

  \[`character(1)`\]  
  Working directory for R process for running jobs. Defaults to the
  working directory currently set during Registry construction (see
  [`getwd`](https://rdrr.io/r/base/getwd.html)). `loadRegistry` uses the
  stored `work.dir`, but you may also explicitly overwrite it, e.g.,
  after switching to another system.

  The provided path will get normalized unless it is given relative to
  the home directory (i.e., starting with “~”). Note that some templates
  do not handle relative paths well.

- conf.file:

  \[`character(1)`\]  
  Path to a configuration file which is sourced while the registry is
  created. In the configuration file you can define how batchtools
  interacts with the system via
  [`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md).
  Separating the configuration of the underlying host system from the R
  code allows to easily move computation to another site.

  The file lookup is implemented in the internal (but exported) function
  `findConfFile` which returns the first file found of the following
  candidates:

  1.  File “batchtools.conf.R” in the path specified by the environment
      variable “R_BATCHTOOLS_SEARCH_PATH”.

  2.  File “batchtools.conf.R” in the current working directory.

  3.  File “config.R” in the user configuration directory as reported by
      `rappdirs::user_config_dir("batchtools", expand = FALSE)`
      (depending on OS, e.g., on linux this usually resolves to
      “~/.config/batchtools/config.R”).

  4.  “.batchtools.conf.R” in the home directory (“~”).

  5.  “config.R” in the site config directory as reported by
      `rappdirs::site_config_dir("batchtools")` (depending on OS). This
      file can be used for admins to set sane defaults for a computation
      site.

  Set to `NA` if you want to suppress reading any configuration file. If
  a configuration file is found, it gets sourced inside the environment
  of the registry after the defaults for all variables are set.
  Therefore you can set and overwrite slots, e.g.
  `default.resources = list(walltime = 3600)` to set default resources
  or “max.concurrent.jobs” to limit the number of jobs allowed to run
  simultaneously on the system.

- packages:

  \[`character`\]  
  Packages that will always be loaded on each node. Uses
  [`require`](https://rdrr.io/r/base/library.html) internally. Default
  is `character(0)`.

- namespaces:

  \[`character`\]  
  Same as `packages`, but the packages will not be attached. Uses
  [`requireNamespace`](https://rdrr.io/r/base/ns-load.html) internally.
  Default is `character(0)`.

- source:

  \[`character`\]  
  Files which should be sourced on the slaves prior to executing a job.
  Calls [`sys.source`](https://rdrr.io/r/base/sys.source.html) using the
  [`.GlobalEnv`](https://rdrr.io/r/base/environment.html).

- load:

  \[`character`\]  
  Files which should be loaded on the slaves prior to executing a job.
  Calls [`load`](https://rdrr.io/r/base/load.html) using the
  [`.GlobalEnv`](https://rdrr.io/r/base/environment.html).

- seed:

  \[`integer(1)`\]  
  Start seed for jobs. Each job uses the (`seed` + `job.id`) as seed.
  Default is a random integer between 1 and 32768. Note that there is an
  additional seeding mechanism to synchronize instantiation of
  [`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md)s
  in a `ExperimentRegistry`.

- make.default:

  \[`logical(1)`\]  
  If set to `TRUE`, the created registry is saved inside the package
  namespace and acts as default registry. You might want to switch this
  off if you work with multiple registries simultaneously. Default is
  `TRUE`.

## Value

\[`ExperimentRegistry`\].

## Examples

``` r
tmp = makeExperimentRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'

# Definde one problem, two algorithms and add them with some parameters:
addProblem(reg = tmp, "p1",
  fun = function(job, data, n, mean, sd, ...) rnorm(n, mean = mean, sd = sd))
#> Adding problem 'p1'
addAlgorithm(reg = tmp, "a1", fun = function(job, data, instance, ...) mean(instance))
#> Adding algorithm 'a1'
addAlgorithm(reg = tmp, "a2", fun = function(job, data, instance, ...) median(instance))
#> Adding algorithm 'a2'
ids = addExperiments(reg = tmp, list(p1 = data.table::CJ(n = c(50, 100), mean = -2:2, sd = 1:4)))
#> Adding 40 experiments ('p1'[40] x 'a1'[1] x repls[1]) ...
#> Adding 40 experiments ('p1'[40] x 'a2'[1] x repls[1]) ...

# Overview over defined experiments:
tmp$problems
#> [1] "p1"
tmp$algorithms
#> [1] "a1" "a2"
summarizeExperiments(reg = tmp)
#>    problem algorithm .count
#>     <char>    <char>  <int>
#> 1:      p1        a1     40
#> 2:      p1        a2     40
summarizeExperiments(reg = tmp, by = c("problem", "algorithm", "n"))
#>    problem algorithm     n .count
#>     <char>    <char> <num>  <int>
#> 1:      p1        a1    50     20
#> 2:      p1        a1   100     20
#> 3:      p1        a2    50     20
#> 4:      p1        a2   100     20
ids = findExperiments(prob.pars = (n == 50), reg = tmp)
print(unwrap(getJobPars(ids, reg = tmp)))
#> Key: <job.id>
#>     job.id problem algorithm     n  mean    sd
#>      <int>  <char>    <char> <num> <int> <int>
#>  1:      1      p1        a1    50    -2     1
#>  2:      2      p1        a1    50    -2     2
#>  3:      3      p1        a1    50    -2     3
#>  4:      4      p1        a1    50    -2     4
#>  5:      5      p1        a1    50    -1     1
#>  6:      6      p1        a1    50    -1     2
#>  7:      7      p1        a1    50    -1     3
#>  8:      8      p1        a1    50    -1     4
#>  9:      9      p1        a1    50     0     1
#> 10:     10      p1        a1    50     0     2
#> 11:     11      p1        a1    50     0     3
#> 12:     12      p1        a1    50     0     4
#> 13:     13      p1        a1    50     1     1
#> 14:     14      p1        a1    50     1     2
#> 15:     15      p1        a1    50     1     3
#> 16:     16      p1        a1    50     1     4
#> 17:     17      p1        a1    50     2     1
#> 18:     18      p1        a1    50     2     2
#> 19:     19      p1        a1    50     2     3
#> 20:     20      p1        a1    50     2     4
#> 21:     41      p1        a2    50    -2     1
#> 22:     42      p1        a2    50    -2     2
#> 23:     43      p1        a2    50    -2     3
#> 24:     44      p1        a2    50    -2     4
#> 25:     45      p1        a2    50    -1     1
#> 26:     46      p1        a2    50    -1     2
#> 27:     47      p1        a2    50    -1     3
#> 28:     48      p1        a2    50    -1     4
#> 29:     49      p1        a2    50     0     1
#> 30:     50      p1        a2    50     0     2
#> 31:     51      p1        a2    50     0     3
#> 32:     52      p1        a2    50     0     4
#> 33:     53      p1        a2    50     1     1
#> 34:     54      p1        a2    50     1     2
#> 35:     55      p1        a2    50     1     3
#> 36:     56      p1        a2    50     1     4
#> 37:     57      p1        a2    50     2     1
#> 38:     58      p1        a2    50     2     2
#> 39:     59      p1        a2    50     2     3
#> 40:     60      p1        a2    50     2     4
#>     job.id problem algorithm     n  mean    sd

# Submit jobs
submitJobs(reg = tmp)
#> Submitting 80 jobs in 80 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE

# Reduce the results of algorithm a1
ids.mean = findExperiments(algo.name = "a1", reg = tmp)
reduceResults(ids.mean, fun = function(aggr, res, ...) c(aggr, res), reg = tmp)
#>  [1] -1.98469630 -2.06425842 -1.57829424 -1.54085458 -0.83801253 -1.03200064
#>  [7] -0.83647536 -0.22817269  0.05267963  0.32063225  0.66292266 -0.84019695
#> [13]  0.76945500  1.50780734  0.75043834  0.46866849  2.03726918  2.33474808
#> [19]  2.52740967  0.94690547 -1.84481475 -1.93439574 -2.08432449 -1.74409243
#> [25] -0.93044354 -0.86852550 -0.91917690 -0.99852013  0.06523844  0.23235414
#> [31] -0.57542230 -0.51186562  1.03348915  0.96256306  0.86972725  1.11434707
#> [37]  1.95386875  2.03545162  2.07137075  2.33586686

# Join info table with all results and calculate mean of results
# grouped by n and algorithm
ids = findDone(reg = tmp)
pars = unwrap(getJobPars(ids, reg = tmp))
results = unwrap(reduceResultsDataTable(ids, fun = function(res) list(res = res), reg = tmp))
tab = ljoin(pars, results)
tab[, list(mres = mean(res)), by = c("n", "algorithm")]
#>        n algorithm        mres
#>    <num>    <char>       <num>
#> 1:    50        a1  0.07179872
#> 2:   100        a1  0.01313478
#> 3:    50        a2  0.01729868
#> 4:   100        a2 -0.07154361
```

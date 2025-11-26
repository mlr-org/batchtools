# Add Experiments to the Registry

Adds experiments (parametrized combinations of problems with algorithms)
to the registry and thereby defines batch jobs.

If multiple problem designs or algorithm designs are provided, they are
combined via the Cartesian product. E.g., if you have two problems `p1`
and `p2` and three algorithms `a1`, `a2` and `a3`, `addExperiments`
creates experiments for all parameters for the combinations `(p1, a1)`,
`(p1, a2)`, `(p1, a3)`, `(p2, a1)`, `(p2, a2)` and `(p2, a3)`.

## Usage

``` r
addExperiments(
  prob.designs = NULL,
  algo.designs = NULL,
  repls = 1L,
  combine = "crossprod",
  reg = getDefaultRegistry()
)
```

## Arguments

- prob.designs:

  \[named list of
  [`data.frame`](https://rdrr.io/r/base/data.frame.html)\]  
  Named list of data frames (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)).
  The name must match the problem name while the column names correspond
  to parameters of the problem. If `NULL`, experiments for all defined
  problems without any parameters are added.

- algo.designs:

  \[named list of
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  or [`data.frame`](https://rdrr.io/r/base/data.frame.html)\]  
  Named list of data frames (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)).
  The name must match the algorithm name while the column names
  correspond to parameters of the algorithm. If `NULL`, experiments for
  all defined algorithms without any parameters are added.

- repls:

  \[[`integer()`](https://rdrr.io/r/base/integer.html)\]  
  Number of replications for each problem design in \`prob.designs\`
  (automatically replicated to the correct length).

- combine:

  \[`character(1)`\]  
  How to combine the rows of a single problem design with the rows of a
  single algorithm design? Default is “crossprod” which combines each
  row of the problem design which each row of the algorithm design in a
  cross-product fashion. Set to “bind” to just
  [`cbind`](https://rdrr.io/r/base/cbind.html) the tables of problem and
  algorithm designs where the shorter table is repeated if necessary.

- reg:

  \[[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)\]  
  Registry. If not explicitly passed, uses the last created registry.

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with ids of added jobs stored in column “job.id”.

## Note

R's `data.frame` converts character vectors to factors by default in R
versions prior to 4.0.0 which frequently resulted in problems using
`addExperiments`. Therefore, this function will warn about factor
variables if the following conditions hold:

1.  R version is \< 4.0.0

2.  The design is passed as a `data.frame`, not a
    [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
    or [`tibble`](https://tibble.tidyverse.org/reference/tibble.html).

3.  The option “stringsAsFactors” is not set or set to `TRUE`.

## See also

Other Experiment:
[`removeExperiments()`](https://batchtools.mlr-org.com/reference/removeExperiments.md),
[`summarizeExperiments()`](https://batchtools.mlr-org.com/reference/summarizeExperiments.md)

## Examples

``` r
tmp = makeExperimentRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'

# add first problem
fun = function(job, data, n, mean, sd, ...) rnorm(n, mean = mean, sd = sd)
addProblem("rnorm", fun = fun, reg = tmp)
#> Adding problem 'rnorm'

# add second problem
fun = function(job, data, n, lambda, ...) rexp(n, rate = lambda)
addProblem("rexp", fun = fun, reg = tmp)
#> Adding problem 'rexp'

# add first algorithm
fun = function(instance, method, ...) if (method == "mean") mean(instance) else median(instance)
addAlgorithm("average", fun = fun, reg = tmp)
#> Adding algorithm 'average'

# add second algorithm
fun = function(instance, ...) sd(instance)
addAlgorithm("deviation", fun = fun, reg = tmp)
#> Adding algorithm 'deviation'

# define problem and algorithm designs
library(data.table)
prob.designs = algo.designs = list()
prob.designs$rnorm = CJ(n = 100, mean = -1:1, sd = 1:5)
prob.designs$rexp = data.table(n = 100, lambda = 1:5)
algo.designs$average = data.table(method = c("mean", "median"))
algo.designs$deviation = data.table()

# add experiments and submit
addExperiments(prob.designs, algo.designs, reg = tmp)
#> Adding 30 experiments ('rnorm'[15] x 'average'[2] x repls[1]) ...
#> Adding 15 experiments ('rnorm'[15] x 'deviation'[1] x repls[1]) ...
#> Adding 10 experiments ('rexp'[5] x 'average'[2] x repls[1]) ...
#> Adding 5 experiments ('rexp'[5] x 'deviation'[1] x repls[1]) ...

# check what has been created
summarizeExperiments(reg = tmp)
#>    problem algorithm .count
#>     <char>    <char>  <int>
#> 1:   rnorm   average     30
#> 2:   rnorm deviation     15
#> 3:    rexp   average     10
#> 4:    rexp deviation      5
unwrap(getJobPars(reg = tmp))
#> Key: <job.id>
#>     job.id problem algorithm     n  mean    sd lambda method
#>      <int>  <char>    <char> <num> <int> <int>  <int> <char>
#>  1:      1   rnorm   average   100    -1     1     NA   mean
#>  2:      2   rnorm   average   100    -1     1     NA median
#>  3:      3   rnorm   average   100    -1     2     NA   mean
#>  4:      4   rnorm   average   100    -1     2     NA median
#>  5:      5   rnorm   average   100    -1     3     NA   mean
#>  6:      6   rnorm   average   100    -1     3     NA median
#>  7:      7   rnorm   average   100    -1     4     NA   mean
#>  8:      8   rnorm   average   100    -1     4     NA median
#>  9:      9   rnorm   average   100    -1     5     NA   mean
#> 10:     10   rnorm   average   100    -1     5     NA median
#> 11:     11   rnorm   average   100     0     1     NA   mean
#> 12:     12   rnorm   average   100     0     1     NA median
#> 13:     13   rnorm   average   100     0     2     NA   mean
#> 14:     14   rnorm   average   100     0     2     NA median
#> 15:     15   rnorm   average   100     0     3     NA   mean
#> 16:     16   rnorm   average   100     0     3     NA median
#> 17:     17   rnorm   average   100     0     4     NA   mean
#> 18:     18   rnorm   average   100     0     4     NA median
#> 19:     19   rnorm   average   100     0     5     NA   mean
#> 20:     20   rnorm   average   100     0     5     NA median
#> 21:     21   rnorm   average   100     1     1     NA   mean
#> 22:     22   rnorm   average   100     1     1     NA median
#> 23:     23   rnorm   average   100     1     2     NA   mean
#> 24:     24   rnorm   average   100     1     2     NA median
#> 25:     25   rnorm   average   100     1     3     NA   mean
#> 26:     26   rnorm   average   100     1     3     NA median
#> 27:     27   rnorm   average   100     1     4     NA   mean
#> 28:     28   rnorm   average   100     1     4     NA median
#> 29:     29   rnorm   average   100     1     5     NA   mean
#> 30:     30   rnorm   average   100     1     5     NA median
#> 31:     31   rnorm deviation   100    -1     1     NA   <NA>
#> 32:     32   rnorm deviation   100    -1     2     NA   <NA>
#> 33:     33   rnorm deviation   100    -1     3     NA   <NA>
#> 34:     34   rnorm deviation   100    -1     4     NA   <NA>
#> 35:     35   rnorm deviation   100    -1     5     NA   <NA>
#> 36:     36   rnorm deviation   100     0     1     NA   <NA>
#> 37:     37   rnorm deviation   100     0     2     NA   <NA>
#> 38:     38   rnorm deviation   100     0     3     NA   <NA>
#> 39:     39   rnorm deviation   100     0     4     NA   <NA>
#> 40:     40   rnorm deviation   100     0     5     NA   <NA>
#> 41:     41   rnorm deviation   100     1     1     NA   <NA>
#> 42:     42   rnorm deviation   100     1     2     NA   <NA>
#> 43:     43   rnorm deviation   100     1     3     NA   <NA>
#> 44:     44   rnorm deviation   100     1     4     NA   <NA>
#> 45:     45   rnorm deviation   100     1     5     NA   <NA>
#> 46:     46    rexp   average   100    NA    NA      1   mean
#> 47:     47    rexp   average   100    NA    NA      1 median
#> 48:     48    rexp   average   100    NA    NA      2   mean
#> 49:     49    rexp   average   100    NA    NA      2 median
#> 50:     50    rexp   average   100    NA    NA      3   mean
#> 51:     51    rexp   average   100    NA    NA      3 median
#> 52:     52    rexp   average   100    NA    NA      4   mean
#> 53:     53    rexp   average   100    NA    NA      4 median
#> 54:     54    rexp   average   100    NA    NA      5   mean
#> 55:     55    rexp   average   100    NA    NA      5 median
#> 56:     56    rexp deviation   100    NA    NA      1   <NA>
#> 57:     57    rexp deviation   100    NA    NA      2   <NA>
#> 58:     58    rexp deviation   100    NA    NA      3   <NA>
#> 59:     59    rexp deviation   100    NA    NA      4   <NA>
#> 60:     60    rexp deviation   100    NA    NA      5   <NA>
#>     job.id problem algorithm     n  mean    sd lambda method
```

# Apply Functions on Results

Applies a function on the results of your finished jobs and thereby
collects them in a [`list`](https://rdrr.io/r/base/list.html) or
[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html).
The later requires the provided function to return a list (or
`data.frame`) of scalar values. See
[`rbindlist`](https://rdatatable.gitlab.io/data.table/reference/rbindlist.html)
for features and limitations of the aggregation.

If not all jobs are terminated, the respective result will be `NULL`.

## Usage

``` r
reduceResultsList(
  ids = NULL,
  fun = NULL,
  ...,
  missing.val,
  reg = getDefaultRegistry()
)

reduceResultsDataTable(
  ids = NULL,
  fun = NULL,
  ...,
  missing.val,
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
  of [`findDone`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- fun:

  \[`function`\]  
  Function to apply to each result. The result is passed unnamed as
  first argument. If `NULL`, the identity is used. If the function has
  the formal argument “job”, the
  [`Job`](https://batchtools.mlr-org.com/reference/JobExperiment.md)/[`Experiment`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  is also passed to the function.

- ...:

  \[`ANY`\]  
  Additional arguments passed to to function `fun`.

- missing.val:

  \[`ANY`\]  
  Value to impute as result for a job which is not finished. If not
  provided and a result is missing, an exception is raised.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

`reduceResultsList` returns a list of the results in the same order as
the provided ids. `reduceResultsDataTable` returns a
[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
with columns “job.id” and additional result columns created via
[`rbindlist`](https://rdatatable.gitlab.io/data.table/reference/rbindlist.html),
sorted by “job.id”.

## Note

If you have thousands of jobs, disabling the progress bar
(`options(batchtools.progress = FALSE)`) can significantly increase the
performance.

## See also

[`reduceResults`](https://batchtools.mlr-org.com/reference/reduceResults.md)

Other Results:
[`batchMapResults()`](https://batchtools.mlr-org.com/reference/batchMapResults.md),
[`loadResult()`](https://batchtools.mlr-org.com/reference/loadResult.md),
[`reduceResults()`](https://batchtools.mlr-org.com/reference/reduceResults.md)

## Examples

``` r
### Example 1 - reduceResultsList
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg1' using cluster functions 'Interactive'
batchMap(function(x) x^2, x = 1:10, reg = tmp)
#> Adding 10 jobs ...
submitJobs(reg = tmp)
#> Submitting 10 jobs in 10 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE
reduceResultsList(fun = sqrt, reg = tmp)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 2
#> 
#> [[3]]
#> [1] 3
#> 
#> [[4]]
#> [1] 4
#> 
#> [[5]]
#> [1] 5
#> 
#> [[6]]
#> [1] 6
#> 
#> [[7]]
#> [1] 7
#> 
#> [[8]]
#> [1] 8
#> 
#> [[9]]
#> [1] 9
#> 
#> [[10]]
#> [1] 10
#> 

### Example 2 - reduceResultsDataTable
tmp = makeExperimentRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg2' using cluster functions 'Interactive'

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
submitJobs(reg = tmp)
#> Submitting 60 jobs in 60 chunks using cluster functions 'Interactive' ...

# collect results and join them with problem and algorithm paramters
res = ijoin(
  getJobPars(reg = tmp),
  reduceResultsDataTable(reg = tmp, fun = function(x) list(res = x))
)
unwrap(res, sep = ".")
#> Key: <job.id>
#>     job.id problem algorithm prob.pars.n prob.pars.mean prob.pars.sd
#>      <int>  <char>    <char>       <num>          <int>        <int>
#>  1:      1   rnorm   average         100             -1            1
#>  2:      2   rnorm   average         100             -1            1
#>  3:      3   rnorm   average         100             -1            2
#>  4:      4   rnorm   average         100             -1            2
#>  5:      5   rnorm   average         100             -1            3
#>  6:      6   rnorm   average         100             -1            3
#>  7:      7   rnorm   average         100             -1            4
#>  8:      8   rnorm   average         100             -1            4
#>  9:      9   rnorm   average         100             -1            5
#> 10:     10   rnorm   average         100             -1            5
#> 11:     11   rnorm   average         100              0            1
#> 12:     12   rnorm   average         100              0            1
#> 13:     13   rnorm   average         100              0            2
#> 14:     14   rnorm   average         100              0            2
#> 15:     15   rnorm   average         100              0            3
#> 16:     16   rnorm   average         100              0            3
#> 17:     17   rnorm   average         100              0            4
#> 18:     18   rnorm   average         100              0            4
#> 19:     19   rnorm   average         100              0            5
#> 20:     20   rnorm   average         100              0            5
#> 21:     21   rnorm   average         100              1            1
#> 22:     22   rnorm   average         100              1            1
#> 23:     23   rnorm   average         100              1            2
#> 24:     24   rnorm   average         100              1            2
#> 25:     25   rnorm   average         100              1            3
#> 26:     26   rnorm   average         100              1            3
#> 27:     27   rnorm   average         100              1            4
#> 28:     28   rnorm   average         100              1            4
#> 29:     29   rnorm   average         100              1            5
#> 30:     30   rnorm   average         100              1            5
#> 31:     31   rnorm deviation         100             -1            1
#> 32:     32   rnorm deviation         100             -1            2
#> 33:     33   rnorm deviation         100             -1            3
#> 34:     34   rnorm deviation         100             -1            4
#> 35:     35   rnorm deviation         100             -1            5
#> 36:     36   rnorm deviation         100              0            1
#> 37:     37   rnorm deviation         100              0            2
#> 38:     38   rnorm deviation         100              0            3
#> 39:     39   rnorm deviation         100              0            4
#> 40:     40   rnorm deviation         100              0            5
#> 41:     41   rnorm deviation         100              1            1
#> 42:     42   rnorm deviation         100              1            2
#> 43:     43   rnorm deviation         100              1            3
#> 44:     44   rnorm deviation         100              1            4
#> 45:     45   rnorm deviation         100              1            5
#> 46:     46    rexp   average         100             NA           NA
#> 47:     47    rexp   average         100             NA           NA
#> 48:     48    rexp   average         100             NA           NA
#> 49:     49    rexp   average         100             NA           NA
#> 50:     50    rexp   average         100             NA           NA
#> 51:     51    rexp   average         100             NA           NA
#> 52:     52    rexp   average         100             NA           NA
#> 53:     53    rexp   average         100             NA           NA
#> 54:     54    rexp   average         100             NA           NA
#> 55:     55    rexp   average         100             NA           NA
#> 56:     56    rexp deviation         100             NA           NA
#> 57:     57    rexp deviation         100             NA           NA
#> 58:     58    rexp deviation         100             NA           NA
#> 59:     59    rexp deviation         100             NA           NA
#> 60:     60    rexp deviation         100             NA           NA
#>     job.id problem algorithm prob.pars.n prob.pars.mean prob.pars.sd
#>     prob.pars.lambda algo.pars.method  result.res
#>                <int>           <char>       <num>
#>  1:               NA             mean -1.04646282
#>  2:               NA           median -0.98817924
#>  3:               NA             mean -0.98147041
#>  4:               NA           median -0.71572615
#>  5:               NA             mean -0.98960904
#>  6:               NA           median -1.11634029
#>  7:               NA             mean -1.14794720
#>  8:               NA           median -1.02123201
#>  9:               NA             mean -0.89159135
#> 10:               NA           median -1.06412662
#> 11:               NA             mean -0.08169784
#> 12:               NA           median  0.03735153
#> 13:               NA             mean  0.18104742
#> 14:               NA           median -0.05614924
#> 15:               NA             mean  0.37579240
#> 16:               NA           median -0.38072242
#> 17:               NA             mean -0.08521923
#> 18:               NA           median  0.45398916
#> 19:               NA             mean -0.10045811
#> 20:               NA           median -0.19449791
#> 21:               NA             mean  0.78673194
#> 22:               NA           median  0.92504454
#> 23:               NA             mean  0.99697058
#> 24:               NA           median  1.03385331
#> 25:               NA             mean  1.37526204
#> 26:               NA           median  1.74294928
#> 27:               NA             mean  0.17279893
#> 28:               NA           median  1.01658972
#> 29:               NA             mean  0.49471707
#> 30:               NA           median  1.38093271
#> 31:               NA             <NA>  1.13768364
#> 32:               NA             <NA>  2.03163450
#> 33:               NA             <NA>  2.80540249
#> 34:               NA             <NA>  3.94875073
#> 35:               NA             <NA>  5.02220675
#> 36:               NA             <NA>  0.96765081
#> 37:               NA             <NA>  1.99891667
#> 38:               NA             <NA>  3.02944762
#> 39:               NA             <NA>  3.42663032
#> 40:               NA             <NA>  4.99733553
#> 41:               NA             <NA>  0.92584637
#> 42:               NA             <NA>  1.80978848
#> 43:               NA             <NA>  2.67116574
#> 44:               NA             <NA>  4.39848556
#> 45:               NA             <NA>  5.97208145
#> 46:                1             mean  1.04594946
#> 47:                1           median  0.66706890
#> 48:                2             mean  0.51960923
#> 49:                2           median  0.32914477
#> 50:                3             mean  0.31718344
#> 51:                3           median  0.25721963
#> 52:                4             mean  0.25805113
#> 53:                4           median  0.17615608
#> 54:                5             mean  0.21049678
#> 55:                5           median  0.15978693
#> 56:                1             <NA>  0.81653996
#> 57:                2             <NA>  0.50625858
#> 58:                3             <NA>  0.33797922
#> 59:                4             <NA>  0.21772032
#> 60:                5             <NA>  0.19084039
#>     prob.pars.lambda algo.pars.method  result.res
```

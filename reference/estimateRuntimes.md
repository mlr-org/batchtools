# Estimate Remaining Runtimes

Estimates the runtimes of jobs using the random forest implemented in
ranger. Observed runtimes are retrieved from the
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)
and runtimes are predicted for unfinished jobs.

The estimated remaining time is calculated in the `print` method. You
may also pass `n` here to determine the number of parallel jobs which is
then used in a simple Longest Processing Time (LPT) algorithm to give an
estimate for the parallel runtime.

## Usage

``` r
estimateRuntimes(tab, ..., reg = getDefaultRegistry())

# S3 method for class 'RuntimeEstimate'
print(x, n = 1L, ...)
```

## Arguments

- tab:

  \[[`data.table`](https://rdrr.io/pkg/data.table/man/data.table.html)\]  
  Table with column “job.id” and additional columns to predict the
  runtime. Observed runtimes will be looked up in the registry and serve
  as dependent variable. All columns in `tab` except “job.id” will be
  passed to
  [`ranger`](http://imbs-hl.github.io/ranger/reference/ranger.md) as
  independent variables to fit the model.

- ...:

  \[ANY\]  
  Additional parameters passed to
  [`ranger`](http://imbs-hl.github.io/ranger/reference/ranger.md).
  Ignored for the `print` method.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

- x:

  \[`RuntimeEstimate`\]  
  Object to print.

- n:

  \[`integer(1)`\]  
  Number of parallel jobs to assume for runtime estimation.

## Value

\[`RuntimeEstimate`\] which is a `list` with two named elements:
“runtimes” is a
[`data.table`](https://rdrr.io/pkg/data.table/man/data.table.html) with
columns “job.id”, “runtime” (in seconds) and “type” (“estimated” if
runtime is estimated, “observed” if runtime was observed). The other
element of the list named “model”\] contains the fitted random forest
object.

## See also

[`binpack`](https://batchtools.mlr-org.com/reference/chunk.md) and
[`lpt`](https://batchtools.mlr-org.com/reference/chunk.md) to chunk jobs
according to their estimated runtimes.

## Examples

``` r
# Create a simple toy registry
set.seed(1)
tmp = makeExperimentRegistry(file.dir = NA, make.default = FALSE, seed = 1)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
addProblem(name = "iris", data = iris, fun = function(data, ...) nrow(data), reg = tmp)
#> Adding problem 'iris'
addAlgorithm(name = "nrow", function(instance, ...) nrow(instance), reg = tmp)
#> Adding algorithm 'nrow'
addAlgorithm(name = "ncol", function(instance, ...) ncol(instance), reg = tmp)
#> Adding algorithm 'ncol'
addExperiments(algo.designs = list(nrow = data.table::CJ(x = 1:50, y = letters[1:5])), reg = tmp)
#> Adding 250 experiments ('iris'[1] x 'nrow'[250] x repls[1]) ...
addExperiments(algo.designs = list(ncol = data.table::CJ(x = 1:50, y = letters[1:5])), reg = tmp)
#> Adding 250 experiments ('iris'[1] x 'ncol'[250] x repls[1]) ...

# We use the job parameters to predict runtimes
tab = unwrap(getJobPars(reg = tmp))

# First we need to submit some jobs so that the forest can train on some data.
# Thus, we just sample some jobs from the registry while grouping by factor variables.
library(data.table)
ids = tab[, .SD[sample(nrow(.SD), 5)], by = c("problem", "algorithm", "y")]
setkeyv(ids, "job.id")
submitJobs(ids, reg = tmp)
#> Submitting 50 jobs in 50 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE

# We "simulate" some more realistic runtimes here to demonstrate the functionality:
# - Algorithm "ncol" is 5 times more expensive than "nrow"
# - x has no effect on the runtime
# - If y is "a" or "b", the runtimes are really high
runtime = function(algorithm, x, y) {
  ifelse(algorithm == "nrow", 100L, 500L) + 1000L * (y %in% letters[1:2])
}
tmp$status[ids, done := done + tab[ids, runtime(algorithm, x, y)]]
#> Key: <job.id>
#>      job.id def.id  submitted    started       done  error mem.used resource.id
#>       <int>  <int>      <num>      <num>      <num> <char>    <num>       <int>
#>   1:      1      1         NA         NA         NA   <NA>       NA          NA
#>   2:      2      2         NA         NA         NA   <NA>       NA          NA
#>   3:      3      3         NA         NA         NA   <NA>       NA          NA
#>   4:      4      4         NA         NA         NA   <NA>       NA          NA
#>   5:      5      5         NA         NA         NA   <NA>       NA          NA
#>  ---                                                                           
#> 496:    496    496         NA         NA         NA   <NA>       NA          NA
#> 497:    497    497         NA         NA         NA   <NA>       NA          NA
#> 498:    498    498         NA         NA         NA   <NA>       NA          NA
#> 499:    499    499 1789914492 1789914492 1789914992   <NA>       NA           1
#> 500:    500    500         NA         NA         NA   <NA>       NA          NA
#>           batch.id log.file                            job.hash job.name  repl
#>             <char>   <char>                              <char>   <char> <int>
#>   1:          <NA>     <NA>                                <NA>     <NA>     1
#>   2:          <NA>     <NA>                                <NA>     <NA>     1
#>   3:          <NA>     <NA>                                <NA>     <NA>     1
#>   4:          <NA>     <NA>                                <NA>     <NA>     1
#>   5:          <NA>     <NA>                                <NA>     <NA>     1
#>  ---                                                                          
#> 496:          <NA>     <NA>                                <NA>     <NA>     1
#> 497:          <NA>     <NA>                                <NA>     <NA>     1
#> 498:          <NA>     <NA>                                <NA>     <NA>     1
#> 499: cfInteractive     <NA> job9da579a638675c4b4634074a3bea3af8     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0340 secs
#>  2:     42    iris      nrow     9      b 1100.0335 secs
#>  3:     47    iris      nrow    10      b 1100.0332 secs
#>  4:     66    iris      nrow    14      a 1100.0369 secs
#>  5:     73    iris      nrow    15      c  100.0333 secs
#>  6:     75    iris      nrow    15      e  100.0336 secs
#>  7:     86    iris      nrow    18      a 1100.0332 secs
#>  8:    100    iris      nrow    20      e  100.0333 secs
#>  9:    101    iris      nrow    21      a 1100.0338 secs
#> 10:    103    iris      nrow    21      c  100.0332 secs
#> 11:    123    iris      nrow    25      c  100.0335 secs
#> 12:    125    iris      nrow    25      e  100.0340 secs
#> 13:    161    iris      nrow    33      a 1100.0336 secs
#> 14:    165    iris      nrow    33      e  100.0332 secs
#> 15:    169    iris      nrow    34      d  100.0371 secs
#> 16:    183    iris      nrow    37      c  100.0332 secs
#> 17:    184    iris      nrow    37      d  100.0333 secs
#> 18:    203    iris      nrow    41      c  100.0333 secs
#> 19:    207    iris      nrow    42      b 1100.0331 secs
#> 20:    209    iris      nrow    42      d  100.0332 secs
#> 21:    220    iris      nrow    44      e  100.0331 secs
#> 22:    227    iris      nrow    46      b 1100.0330 secs
#> 23:    229    iris      nrow    46      d  100.0340 secs
#> 24:    231    iris      nrow    47      a 1100.0337 secs
#> 25:    244    iris      nrow    49      d  100.0340 secs
#> 26:    260    iris      ncol     2      e  500.0376 secs
#> 27:    276    iris      ncol     6      a 1500.0331 secs
#> 28:    278    iris      ncol     6      c  500.0333 secs
#> 29:    279    iris      ncol     6      d  500.0331 secs
#> 30:    296    iris      ncol    10      a 1500.0337 secs
#> 31:    320    iris      ncol    14      e  500.0367 secs
#> 32:    340    iris      ncol    18      e  500.0332 secs
#> 33:    347    iris      ncol    20      b 1500.0335 secs
#> 34:    363    iris      ncol    23      c  500.0331 secs
#> 35:    369    iris      ncol    24      d  500.0339 secs
#> 36:    373    iris      ncol    25      c  500.0377 secs
#> 37:    387    iris      ncol    28      b 1500.0329 secs
#> 38:    410    iris      ncol    32      e  500.0335 secs
#> 39:    421    iris      ncol    35      a 1500.0336 secs
#> 40:    436    iris      ncol    38      a 1500.0337 secs
#> 41:    444    iris      ncol    39      d  500.0371 secs
#> 42:    448    iris      ncol    40      c  500.0335 secs
#> 43:    456    iris      ncol    42      a 1500.0332 secs
#> 44:    459    iris      ncol    42      d  500.0335 secs
#> 45:    467    iris      ncol    44      b 1500.0373 secs
#> 46:    468    iris      ncol    44      c  500.0333 secs
#> 47:    475    iris      ncol    45      e  500.0330 secs
#> 48:    482    iris      ncol    47      b 1500.0335 secs
#> 49:    492    iris      ncol    49      b 1500.0372 secs
#> 50:    499    iris      ncol    50      d  500.0335 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.7s
#>   Remaining: 3d 17h 37m 24.4s
#>   Total    : 4d 03h 20m 46.1s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1105.4880
#>   2:      2    iris      nrow     1      b estimated 1089.2820
#>   3:      3    iris      nrow     1      c estimated  338.2405
#>   4:      4    iris      nrow     1      d estimated  318.1065
#>   5:      5    iris      nrow     1      e estimated  318.1505
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1383.8285
#> 497:    497    iris      ncol    50      b estimated 1391.0788
#> 498:    498    iris      ncol    50      c estimated  618.4913
#> 499:    499    iris      ncol    50      d  observed  500.0335
#> 500:    500    iris      ncol    50      e estimated  577.8834
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.7s
#>   Remaining: 3d 17h 37m 24.4s
#>   Parallel : 0d 08h 58m 25.8s
#>   Total    : 4d 03h 20m 46.1s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1421.1254
#>   2:    461 estimated 1419.7317
#>   3:    462 estimated 1415.9912
#>   4:    457 estimated 1415.9912
#>   5:    472 estimated 1414.9450
#>  ---                           
#> 446:    194 estimated  133.3101
#> 447:    185 estimated  132.9607
#> 448:    174 estimated  131.1220
#> 449:    204 estimated  130.1597
#> 450:    179 estimated  129.9747
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.4880    47
#>   2:      2 estimated 1089.2820    52
#>   3:      3 estimated  338.2405    54
#>   4:      4 estimated  318.1065    71
#>   5:      5 estimated  318.1505    34
#>  ---                                 
#> 446:    495 estimated  584.8180    15
#> 447:    496 estimated 1383.8285    20
#> 448:    497 estimated 1391.0788    13
#> 449:    498 estimated  618.4913     4
#> 450:    500 estimated  577.8834    22
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.4880    47
#>   2:      2 estimated 1089.2820    52
#>   3:      3 estimated  338.2405    54
#>   4:      4 estimated  318.1065    71
#>   5:      5 estimated  318.1505    34
#>  ---                                 
#> 446:    495 estimated  584.8180    15
#> 447:    496 estimated 1383.8285    20
#> 448:    497 estimated 1391.0788    13
#> 449:    498 estimated  618.4913     4
#> 450:    500 estimated  577.8834    22
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3491.266
#>  2:    52 3595.056
#>  3:    54 3590.348
#>  4:    71 3488.547
#>  5:    34 3592.826
#>  6:    48 3485.066
#>  7:    55 3584.553
#>  8:    72 3485.265
#>  9:    51 3597.003
#> 10:    56 3573.740
#> 11:    73 3478.537
#> 12:    69 3493.033
#> 13:    53 3599.909
#> 14:    57 3565.360
#> 15:    74 3599.528
#> 16:    70 3490.306
#> 17:    46 3515.547
#> 18:    50 3599.756
#> 19:    38 3595.643
#> 20:    64 3516.230
#> 21:    35 3593.253
#> 22:    43 3569.983
#> 23:    65 3512.019
#> 24:    39 3599.367
#> 25:    61 3530.541
#> 26:    40 3599.056
#> 27:    59 3543.113
#> 28:    58 3551.700
#> 29:    49 3477.654
#> 30:    42 3581.126
#> 31:    60 3533.808
#> 32:    62 3528.179
#> 33:    41 3587.464
#> 34:    37 3599.596
#> 35:    36 3599.638
#> 36:    44 3540.562
#> 37:    63 3517.999
#> 38:    66 3506.334
#> 39:    45 3539.762
#> 40:    67 3505.665
#> 41:    68 3502.969
#> 42:    28 3594.895
#> 43:    24 3598.343
#> 44:    25 3590.652
#> 45:    27 3597.007
#> 46:    29 3571.229
#> 47:    26 3588.139
#> 48:    75 3599.317
#> 49:    20 3521.754
#> 50:     9 3588.994
#> 51:    21 3517.062
#> 52:     6 3591.511
#> 53:     8 3593.771
#> 54:    12 3560.130
#> 55:     5 3596.956
#> 56:    10 3575.851
#> 57:    32 3599.898
#> 58:    11 3572.875
#> 59:    33 3599.228
#> 60:    82 3471.057
#> 61:    84 3598.855
#> 62:    85 3589.212
#> 63:    76 3598.443
#> 64:     3 3599.929
#> 65:    80 3492.694
#> 66:    81 3483.062
#> 67:    77 3528.725
#> 68:    87 3568.989
#> 69:    91 2293.682
#> 70:    79 3503.848
#> 71:    89 3550.522
#> 72:    88 3559.122
#> 73:    78 3515.010
#> 74:     2 3599.997
#> 75:    83 3599.893
#> 76:    86 3578.383
#> 77:    90 3528.472
#> 78:     4 3599.692
#> 79:     7 3599.569
#> 80:    30 3563.744
#> 81:    18 3571.580
#> 82:    13 3597.197
#> 83:    22 3598.715
#> 84:    19 3568.414
#> 85:    16 3585.782
#> 86:    31 3548.302
#> 87:    17 3578.161
#> 88:    23 3598.799
#> 89:    15 3593.089
#> 90:    14 3596.282
#> 91:     1 3470.307
#>     chunk  runtime
#>     <int>    <num>
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into 10 chunks with similar runtime
ids = est$runtimes[type == "estimated"]
ids[, chunk := lpt(runtime, 10)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.4880     6
#>   2:      2 estimated 1089.2820     1
#>   3:      3 estimated  338.2405     3
#>   4:      4 estimated  318.1065     7
#>   5:      5 estimated  318.1505     1
#>  ---                                 
#> 446:    495 estimated  584.8180     1
#> 447:    496 estimated 1383.8285     2
#> 448:    497 estimated 1391.0788     4
#> 449:    498 estimated  618.4913     6
#> 450:    500 estimated  577.8834     5
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     6 32228.15
#>  2:     1 32232.33
#>  3:     3 32228.97
#>  4:     7 32305.79
#>  5:     8 32227.82
#>  6:     9 32228.05
#>  7:    10 32305.47
#>  8:     2 32291.68
#>  9:     5 32304.83
#> 10:     4 32291.35
```

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

  \[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]  
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
[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
with columns “job.id”, “runtime” (in seconds) and “type” (“estimated” if
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
#> 499:    499    499 1764152569 1764152569 1764153069   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job9a2771e603043c31788ff87c02c0103d     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0330 secs
#>  2:     42    iris      nrow     9      b 1100.0321 secs
#>  3:     47    iris      nrow    10      b 1100.0322 secs
#>  4:     66    iris      nrow    14      a 1100.0322 secs
#>  5:     73    iris      nrow    15      c  100.0322 secs
#>  6:     75    iris      nrow    15      e  100.0319 secs
#>  7:     86    iris      nrow    18      a 1100.0318 secs
#>  8:    100    iris      nrow    20      e  100.0319 secs
#>  9:    101    iris      nrow    21      a 1100.0322 secs
#> 10:    103    iris      nrow    21      c  100.0325 secs
#> 11:    123    iris      nrow    25      c  100.0322 secs
#> 12:    125    iris      nrow    25      e  100.0320 secs
#> 13:    161    iris      nrow    33      a 1100.0321 secs
#> 14:    165    iris      nrow    33      e  100.0320 secs
#> 15:    169    iris      nrow    34      d  100.0319 secs
#> 16:    183    iris      nrow    37      c  100.0320 secs
#> 17:    184    iris      nrow    37      d  100.0319 secs
#> 18:    203    iris      nrow    41      c  100.0320 secs
#> 19:    207    iris      nrow    42      b 1100.0318 secs
#> 20:    209    iris      nrow    42      d  100.0318 secs
#> 21:    220    iris      nrow    44      e  100.0319 secs
#> 22:    227    iris      nrow    46      b 1100.0319 secs
#> 23:    229    iris      nrow    46      d  100.0317 secs
#> 24:    231    iris      nrow    47      a 1100.0319 secs
#> 25:    244    iris      nrow    49      d  100.0317 secs
#> 26:    260    iris      ncol     2      e  500.0318 secs
#> 27:    276    iris      ncol     6      a 1500.0320 secs
#> 28:    278    iris      ncol     6      c  500.0333 secs
#> 29:    279    iris      ncol     6      d  500.0325 secs
#> 30:    296    iris      ncol    10      a 1500.0326 secs
#> 31:    320    iris      ncol    14      e  500.0324 secs
#> 32:    340    iris      ncol    18      e  500.0323 secs
#> 33:    347    iris      ncol    20      b 1500.0325 secs
#> 34:    363    iris      ncol    23      c  500.0337 secs
#> 35:    369    iris      ncol    24      d  500.0329 secs
#> 36:    373    iris      ncol    25      c  500.0328 secs
#> 37:    387    iris      ncol    28      b 1500.0329 secs
#> 38:    410    iris      ncol    32      e  500.0325 secs
#> 39:    421    iris      ncol    35      a 1500.0325 secs
#> 40:    436    iris      ncol    38      a 1500.0324 secs
#> 41:    444    iris      ncol    39      d  500.0327 secs
#> 42:    448    iris      ncol    40      c  500.0325 secs
#> 43:    456    iris      ncol    42      a 1500.0324 secs
#> 44:    459    iris      ncol    42      d  500.0333 secs
#> 45:    467    iris      ncol    44      b 1500.0334 secs
#> 46:    468    iris      ncol    44      c  500.0330 secs
#> 47:    475    iris      ncol    45      e  500.0331 secs
#> 48:    482    iris      ncol    47      b 1500.0332 secs
#> 49:    492    iris      ncol    49      b 1500.0383 secs
#> 50:    499    iris      ncol    50      d  500.0337 secs
#>     job.id problem algorithm     x      y   time.running

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.6s
#>   Remaining: 3d 17h 35m 47.4s
#>   Total    : 4d 03h 19m 9.0s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1104.0461
#>   2:      2    iris      nrow     1      b estimated 1088.0005
#>   3:      3    iris      nrow     1      c estimated  338.5989
#>   4:      4    iris      nrow     1      d estimated  318.2378
#>   5:      5    iris      nrow     1      e estimated  317.9085
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1387.8280
#> 497:    497    iris      ncol    50      b estimated 1394.9184
#> 498:    498    iris      ncol    50      c estimated  618.9306
#> 499:    499    iris      ncol    50      d  observed  500.0337
#> 500:    500    iris      ncol    50      e estimated  580.0825
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.6s
#>   Remaining: 3d 17h 35m 47.4s
#>   Parallel : 0d 08h 58m 16.3s
#>   Total    : 4d 03h 19m 9.0s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1424.2072
#>   2:    461 estimated 1420.8138
#>   3:    472 estimated 1417.8669
#>   4:    462 estimated 1416.9134
#>   5:    457 estimated 1416.9133
#>  ---                           
#> 446:    185 estimated  133.4590
#> 447:    204 estimated  132.9087
#> 448:    189 estimated  132.4590
#> 449:    174 estimated  131.4416
#> 450:    179 estimated  130.2949
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1104.0461    48
#>   2:      2 estimated 1088.0005    52
#>   3:      3 estimated  338.5989    37
#>   4:      4 estimated  318.2378    33
#>   5:      5 estimated  317.9085    70
#>  ---                                 
#> 446:    495 estimated  585.0171    15
#> 447:    496 estimated 1387.8280    17
#> 448:    497 estimated 1394.9184    13
#> 449:    498 estimated  618.9306     4
#> 450:    500 estimated  580.0825    17
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1104.0461    48
#>   2:      2 estimated 1088.0005    52
#>   3:      3 estimated  338.5989    37
#>   4:      4 estimated  318.2378    33
#>   5:      5 estimated  317.9085    70
#>  ---                                 
#> 446:    495 estimated  585.0171    15
#> 447:    496 estimated 1387.8280    17
#> 448:    497 estimated 1394.9184    13
#> 449:    498 estimated  618.9306     4
#> 450:    500 estimated  580.0825    17
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    48 3486.521
#>  2:    52 3598.806
#>  3:    37 3595.674
#>  4:    33 3598.121
#>  5:    70 3493.071
#>  6:    49 3480.762
#>  7:    54 3589.919
#>  8:    51 3594.607
#>  9:    71 3491.029
#> 10:    53 3596.295
#> 11:    55 3585.848
#> 12:    68 3499.083
#> 13:    72 3488.600
#> 14:    56 3576.969
#> 15:    69 3495.780
#> 16:    73 3482.256
#> 17:    46 3518.845
#> 18:    50 3599.764
#> 19:    42 3577.707
#> 20:    64 3512.924
#> 21:    66 3509.266
#> 22:    43 3574.094
#> 23:    65 3511.738
#> 24:    67 3507.024
#> 25:    38 3599.959
#> 26:    35 3599.586
#> 27:    60 3535.969
#> 28:    47 3494.137
#> 29:    39 3598.195
#> 30:    36 3598.731
#> 31:    41 3587.235
#> 32:    58 3548.470
#> 33:    59 3543.101
#> 34:    40 3593.835
#> 35:    57 3564.195
#> 36:    44 3540.210
#> 37:    62 3521.418
#> 38:    61 3527.278
#> 39:    45 3538.939
#> 40:    63 3515.904
#> 41:    34 3599.823
#> 42:    27 3598.451
#> 43:    23 3599.621
#> 44:    24 3594.031
#> 45:    25 3597.491
#> 46:    29 3564.062
#> 47:    26 3582.342
#> 48:    75 3599.964
#> 49:    20 3517.893
#> 50:    74 3478.383
#> 51:     8 3593.415
#> 52:    31 3599.868
#> 53:     6 3592.027
#> 54:     7 3595.832
#> 55:    12 3558.434
#> 56:     5 3593.649
#> 57:    11 3572.833
#> 58:    10 3578.199
#> 59:    32 3599.610
#> 60:    83 3599.773
#> 61:    82 3599.642
#> 62:    76 3590.200
#> 63:    81 3472.972
#> 64:     3 3599.877
#> 65:    79 3491.740
#> 66:    80 3481.754
#> 67:    77 3522.931
#> 68:    86 3573.502
#> 69:    91 2163.640
#> 70:    89 3547.870
#> 71:    78 3507.950
#> 72:    88 3556.205
#> 73:     4 3596.032
#> 74:    90 3529.595
#> 75:    84 3591.850
#> 76:    85 3580.713
#> 77:     2 3599.972
#> 78:    87 3564.720
#> 79:     9 3587.892
#> 80:    22 3598.898
#> 81:    18 3572.611
#> 82:    16 3588.081
#> 83:    21 3599.813
#> 84:    19 3568.880
#> 85:    17 3582.218
#> 86:    30 3551.126
#> 87:    13 3598.089
#> 88:    28 3572.702
#> 89:    15 3598.504
#> 90:    14 3599.101
#> 91:     1 3470.710
#>     chunk  runtime
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into 10 chunks with similar runtime
ids = est$runtimes[type == "estimated"]
ids[, chunk := lpt(runtime, 10)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1104.0461     8
#>   2:      2 estimated 1088.0005     3
#>   3:      3 estimated  338.5989     8
#>   4:      4 estimated  318.2378     3
#>   5:      5 estimated  317.9085     1
#>  ---                                 
#> 446:    495 estimated  585.0171     8
#> 447:    496 estimated 1387.8280     3
#> 448:    497 estimated 1394.9184     7
#> 449:    498 estimated  618.9306     5
#> 450:    500 estimated  580.0825     5
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     8 32219.58
#>  2:     3 32224.97
#>  3:     1 32278.64
#>  4:     5 32279.15
#>  5:     6 32219.58
#>  6:     9 32219.46
#>  7:    10 32295.54
#>  8:     4 32294.65
#>  9:     2 32296.33
#> 10:     7 32219.47
```

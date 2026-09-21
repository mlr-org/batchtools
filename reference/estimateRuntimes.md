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
#> 499:    499    499 1790003394 1790003394 1790003894   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job43dc144f74ffe17d9c4f9b8dfa265d03     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0348 secs
#>  2:     42    iris      nrow     9      b 1100.0349 secs
#>  3:     47    iris      nrow    10      b 1100.0348 secs
#>  4:     66    iris      nrow    14      a 1100.0383 secs
#>  5:     73    iris      nrow    15      c  100.0350 secs
#>  6:     75    iris      nrow    15      e  100.0348 secs
#>  7:     86    iris      nrow    18      a 1100.0347 secs
#>  8:    100    iris      nrow    20      e  100.0343 secs
#>  9:    101    iris      nrow    21      a 1100.0348 secs
#> 10:    103    iris      nrow    21      c  100.0348 secs
#> 11:    123    iris      nrow    25      c  100.0346 secs
#> 12:    125    iris      nrow    25      e  100.0349 secs
#> 13:    161    iris      nrow    33      a 1100.0347 secs
#> 14:    165    iris      nrow    33      e  100.0344 secs
#> 15:    169    iris      nrow    34      d  100.0385 secs
#> 16:    183    iris      nrow    37      c  100.0345 secs
#> 17:    184    iris      nrow    37      d  100.0350 secs
#> 18:    203    iris      nrow    41      c  100.0349 secs
#> 19:    207    iris      nrow    42      b 1100.0354 secs
#> 20:    209    iris      nrow    42      d  100.0349 secs
#> 21:    220    iris      nrow    44      e  100.0347 secs
#> 22:    227    iris      nrow    46      b 1100.0349 secs
#> 23:    229    iris      nrow    46      d  100.0352 secs
#> 24:    231    iris      nrow    47      a 1100.0352 secs
#> 25:    244    iris      nrow    49      d  100.0351 secs
#> 26:    260    iris      ncol     2      e  500.0387 secs
#> 27:    276    iris      ncol     6      a 1500.0354 secs
#> 28:    278    iris      ncol     6      c  500.0353 secs
#> 29:    279    iris      ncol     6      d  500.0352 secs
#> 30:    296    iris      ncol    10      a 1500.0354 secs
#> 31:    320    iris      ncol    14      e  500.0388 secs
#> 32:    340    iris      ncol    18      e  500.0350 secs
#> 33:    347    iris      ncol    20      b 1500.0348 secs
#> 34:    363    iris      ncol    23      c  500.0348 secs
#> 35:    369    iris      ncol    24      d  500.0353 secs
#> 36:    373    iris      ncol    25      c  500.0395 secs
#> 37:    387    iris      ncol    28      b 1500.0351 secs
#> 38:    410    iris      ncol    32      e  500.0358 secs
#> 39:    421    iris      ncol    35      a 1500.0352 secs
#> 40:    436    iris      ncol    38      a 1500.0353 secs
#> 41:    444    iris      ncol    39      d  500.0397 secs
#> 42:    448    iris      ncol    40      c  500.0353 secs
#> 43:    456    iris      ncol    42      a 1500.0352 secs
#> 44:    459    iris      ncol    42      d  500.0360 secs
#> 45:    467    iris      ncol    44      b 1500.0400 secs
#> 46:    468    iris      ncol    44      c  500.0349 secs
#> 47:    475    iris      ncol    45      e  500.0355 secs
#> 48:    482    iris      ncol    47      b 1500.0351 secs
#> 49:    492    iris      ncol    49      b 1500.0394 secs
#> 50:    499    iris      ncol    50      d  500.0355 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.8s
#>   Remaining: 3d 17h 36m 55.0s
#>   Total    : 4d 03h 20m 16.8s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1105.8894
#>   2:      2    iris      nrow     1      b estimated 1089.8434
#>   3:      3    iris      nrow     1      c estimated  338.6420
#>   4:      4    iris      nrow     1      d estimated  317.7079
#>   5:      5    iris      nrow     1      e estimated  318.5518
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1384.6305
#> 497:    497    iris      ncol    50      b estimated 1391.8808
#> 498:    498    iris      ncol    50      c estimated  618.4932
#> 499:    499    iris      ncol    50      d  observed  500.0355
#> 500:    500    iris      ncol    50      e estimated  578.6855
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.8s
#>   Remaining: 3d 17h 36m 55.0s
#>   Parallel : 0d 08h 58m 21.6s
#>   Total    : 4d 03h 20m 16.8s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1421.1274
#>   2:    461 estimated 1419.7336
#>   3:    462 estimated 1415.9075
#>   4:    457 estimated 1415.9075
#>   5:    472 estimated 1415.0614
#>  ---                           
#> 446:    164 estimated  133.4730
#> 447:    185 estimated  132.9620
#> 448:    174 estimated  131.1234
#> 449:    204 estimated  130.8546
#> 450:    179 estimated  129.9762
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.8894    47
#>   2:      2 estimated 1089.8434    52
#>   3:      3 estimated  338.6420    54
#>   4:      4 estimated  317.7079    71
#>   5:      5 estimated  318.5518    34
#>  ---                                 
#> 446:    495 estimated  584.8201    15
#> 447:    496 estimated 1384.6305    19
#> 448:    497 estimated 1391.8808    13
#> 449:    498 estimated  618.4932     4
#> 450:    500 estimated  578.6855    19
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.8894    47
#>   2:      2 estimated 1089.8434    52
#>   3:      3 estimated  338.6420    54
#>   4:      4 estimated  317.7079    71
#>   5:      5 estimated  318.5518    34
#>  ---                                 
#> 446:    495 estimated  584.8201    15
#> 447:    496 estimated 1384.6305    19
#> 448:    497 estimated 1391.8808    13
#> 449:    498 estimated  618.4932     4
#> 450:    500 estimated  578.6855    19
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3491.272
#>  2:    52 3597.142
#>  3:    54 3591.738
#>  4:    71 3486.947
#>  5:    34 3593.232
#>  6:    48 3486.272
#>  7:    55 3585.096
#>  8:    72 3484.225
#>  9:    51 3597.410
#> 10:    56 3574.375
#> 11:    73 3476.862
#> 12:    69 3492.719
#> 13:    53 3593.737
#> 14:    57 3565.680
#> 15:    74 3598.655
#> 16:    70 3489.980
#> 17:    46 3515.552
#> 18:    50 3599.550
#> 19:    38 3595.269
#> 20:    65 3511.054
#> 21:    35 3593.979
#> 22:    43 3569.110
#> 23:    66 3506.047
#> 24:    42 3578.910
#> 25:    63 3524.645
#> 26:    61 3530.734
#> 27:    40 3598.718
#> 28:    59 3542.719
#> 29:    58 3552.020
#> 30:    49 3478.060
#> 31:    39 3599.518
#> 32:    60 3533.733
#> 33:    62 3528.013
#> 34:    41 3588.031
#> 35:    37 3599.203
#> 36:    36 3599.799
#> 37:    44 3539.689
#> 38:    64 3515.603
#> 39:    45 3538.889
#> 40:    68 3501.873
#> 41:    67 3505.357
#> 42:    28 3594.366
#> 43:    25 3589.970
#> 44:    24 3597.823
#> 45:    27 3596.768
#> 46:    29 3569.692
#> 47:    26 3587.900
#> 48:    75 3599.904
#> 49:    20 3521.144
#> 50:     9 3589.937
#> 51:    21 3516.305
#> 52:    11 3562.605
#> 53:     8 3594.978
#> 54:    12 3557.806
#> 55:     5 3596.562
#> 56:     6 3599.698
#> 57:    32 3598.865
#> 58:    10 3576.258
#> 59:    33 3599.463
#> 60:    83 3599.980
#> 61:    84 3594.607
#> 62:    76 3597.737
#> 63:     4 3599.426
#> 64:    81 3483.238
#> 65:    79 3500.494
#> 66:    87 3567.822
#> 67:    91 2294.007
#> 68:    82 3470.644
#> 69:    78 3515.530
#> 70:    89 3549.098
#> 71:    88 3558.973
#> 72:    77 3529.682
#> 73:    90 3528.183
#> 74:    86 3579.143
#> 75:    80 3489.508
#> 76:    85 3586.417
#> 77:     2 3599.801
#> 78:     3 3599.982
#> 79:     7 3597.829
#> 80:    30 3562.630
#> 81:    18 3571.746
#> 82:    13 3597.439
#> 83:    22 3598.138
#> 84:    19 3569.266
#> 85:    16 3585.704
#> 86:    31 3547.178
#> 87:    17 3578.082
#> 88:    23 3598.720
#> 89:    14 3598.210
#> 90:    15 3594.033
#> 91:     1 3470.313
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
#>   1:      1 estimated 1105.8894     6
#>   2:      2 estimated 1089.8434     5
#>   3:      3 estimated  338.6420     5
#>   4:      4 estimated  317.7079     7
#>   5:      5 estimated  318.5518     4
#>  ---                                 
#> 446:    495 estimated  584.8201     8
#> 447:    496 estimated 1384.6305    10
#> 448:    497 estimated 1391.8808     2
#> 449:    498 estimated  618.4932    10
#> 450:    500 estimated  578.6855     6
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     6 32286.67
#>  2:     5 32226.04
#>  3:     7 32286.55
#>  4:     4 32231.54
#>  5:     8 32227.22
#>  6:     3 32226.10
#>  7:     2 32301.01
#>  8:    10 32301.55
#>  9:     9 32301.29
#> 10:     1 32227.04
```

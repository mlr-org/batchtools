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
#> 499:    499    499 1789914307 1789914307 1789914807   <NA>       NA           1
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
#> 499: cfInteractive     <NA> joba2d1aaf6ea8637a62de3a2f715e943dc     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0281 secs
#>  2:     42    iris      nrow     9      b 1100.0280 secs
#>  3:     47    iris      nrow    10      b 1100.0276 secs
#>  4:     66    iris      nrow    14      a 1100.0320 secs
#>  5:     73    iris      nrow    15      c  100.0275 secs
#>  6:     75    iris      nrow    15      e  100.0278 secs
#>  7:     86    iris      nrow    18      a 1100.0278 secs
#>  8:    100    iris      nrow    20      e  100.0276 secs
#>  9:    101    iris      nrow    21      a 1100.0271 secs
#> 10:    103    iris      nrow    21      c  100.0277 secs
#> 11:    123    iris      nrow    25      c  100.0276 secs
#> 12:    125    iris      nrow    25      e  100.0282 secs
#> 13:    161    iris      nrow    33      a 1100.0277 secs
#> 14:    165    iris      nrow    33      e  100.0272 secs
#> 15:    169    iris      nrow    34      d  100.0315 secs
#> 16:    183    iris      nrow    37      c  100.0276 secs
#> 17:    184    iris      nrow    37      d  100.0277 secs
#> 18:    203    iris      nrow    41      c  100.0283 secs
#> 19:    207    iris      nrow    42      b 1100.0276 secs
#> 20:    209    iris      nrow    42      d  100.0277 secs
#> 21:    220    iris      nrow    44      e  100.0278 secs
#> 22:    227    iris      nrow    46      b 1100.0278 secs
#> 23:    229    iris      nrow    46      d  100.0281 secs
#> 24:    231    iris      nrow    47      a 1100.0281 secs
#> 25:    244    iris      nrow    49      d  100.0277 secs
#> 26:    260    iris      ncol     2      e  500.0323 secs
#> 27:    276    iris      ncol     6      a 1500.0280 secs
#> 28:    278    iris      ncol     6      c  500.0281 secs
#> 29:    279    iris      ncol     6      d  500.0278 secs
#> 30:    296    iris      ncol    10      a 1500.0281 secs
#> 31:    320    iris      ncol    14      e  500.0316 secs
#> 32:    340    iris      ncol    18      e  500.0279 secs
#> 33:    347    iris      ncol    20      b 1500.0282 secs
#> 34:    363    iris      ncol    23      c  500.0278 secs
#> 35:    369    iris      ncol    24      d  500.0279 secs
#> 36:    373    iris      ncol    25      c  500.0328 secs
#> 37:    387    iris      ncol    28      b 1500.0278 secs
#> 38:    410    iris      ncol    32      e  500.0282 secs
#> 39:    421    iris      ncol    35      a 1500.0278 secs
#> 40:    436    iris      ncol    38      a 1500.0278 secs
#> 41:    444    iris      ncol    39      d  500.0322 secs
#> 42:    448    iris      ncol    40      c  500.0283 secs
#> 43:    456    iris      ncol    42      a 1500.0279 secs
#> 44:    459    iris      ncol    42      d  500.0281 secs
#> 45:    467    iris      ncol    44      b 1500.0330 secs
#> 46:    468    iris      ncol    44      c  500.0282 secs
#> 47:    475    iris      ncol    45      e  500.0275 secs
#> 48:    482    iris      ncol    47      b 1500.0278 secs
#> 49:    492    iris      ncol    49      b 1500.0319 secs
#> 50:    499    iris      ncol    50      d  500.0281 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.4s
#>   Remaining: 3d 17h 36m 14.1s
#>   Total    : 4d 03h 19m 35.5s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1105.8825
#>   2:      2    iris      nrow     1      b estimated 1089.8365
#>   3:      3    iris      nrow     1      c estimated  337.8349
#>   4:      4    iris      nrow     1      d estimated  317.7009
#>   5:      5    iris      nrow     1      e estimated  318.5449
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1383.8231
#> 497:    497    iris      ncol    50      b estimated 1391.0735
#> 498:    498    iris      ncol    50      c estimated  617.6860
#> 499:    499    iris      ncol    50      d  observed  500.0281
#> 500:    500    iris      ncol    50      e estimated  577.8780
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.4s
#>   Remaining: 3d 17h 36m 14.1s
#>   Parallel : 0d 08h 58m 18.5s
#>   Total    : 4d 03h 19m 35.5s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1421.1201
#>   2:    461 estimated 1419.7263
#>   3:    462 estimated 1415.9003
#>   4:    457 estimated 1415.9002
#>   5:    472 estimated 1415.0542
#>  ---                           
#> 446:    164 estimated  133.9659
#> 447:    185 estimated  133.4550
#> 448:    174 estimated  131.6163
#> 449:    204 estimated  131.6141
#> 450:    179 estimated  130.4690
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.8825    47
#>   2:      2 estimated 1089.8365    51
#>   3:      3 estimated  337.8349    54
#>   4:      4 estimated  317.7009    71
#>   5:      5 estimated  318.5449    34
#>  ---                                 
#> 446:    495 estimated  584.8126    15
#> 447:    496 estimated 1383.8231    20
#> 448:    497 estimated 1391.0735    13
#> 449:    498 estimated  617.6860     4
#> 450:    500 estimated  577.8780    22
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.8825    47
#>   2:      2 estimated 1089.8365    51
#>   3:      3 estimated  337.8349    54
#>   4:      4 estimated  317.7009    71
#>   5:      5 estimated  318.5449    34
#>  ---                                 
#> 446:    495 estimated  584.8126    15
#> 447:    496 estimated 1383.8231    20
#> 448:    497 estimated 1391.0735    13
#> 449:    498 estimated  617.6860     4
#> 450:    500 estimated  577.8780    22
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3491.511
#>  2:    51 3599.698
#>  3:    54 3588.910
#>  4:    71 3486.336
#>  5:    34 3593.204
#>  6:    48 3486.401
#>  7:    52 3597.114
#>  8:    55 3580.981
#>  9:    72 3482.995
#> 10:    68 3493.236
#> 11:    56 3571.618
#> 12:    73 3477.072
#> 13:    69 3491.933
#> 14:    57 3563.566
#> 15:    74 3468.503
#> 16:    70 3489.965
#> 17:    46 3515.791
#> 18:    50 3599.949
#> 19:    38 3595.128
#> 20:    65 3509.216
#> 21:    35 3593.951
#> 22:    43 3569.882
#> 23:    66 3505.247
#> 24:    42 3579.682
#> 25:    62 3526.574
#> 26:    60 3533.523
#> 27:    53 3598.628
#> 28:    40 3598.954
#> 29:    59 3542.898
#> 30:    58 3551.641
#> 31:    49 3478.456
#> 32:    39 3599.497
#> 33:    61 3530.014
#> 34:    41 3587.202
#> 35:    37 3599.175
#> 36:    36 3599.770
#> 37:    44 3541.260
#> 38:    64 3513.074
#> 39:    63 3516.844
#> 40:    45 3540.460
#> 41:    67 3502.128
#> 42:    28 3594.713
#> 43:    25 3589.941
#> 44:    24 3597.794
#> 45:    27 3596.899
#> 46:    29 3570.087
#> 47:    26 3587.872
#> 48:    75 3599.654
#> 49:    20 3521.039
#> 50:     9 3588.734
#> 51:    21 3516.187
#> 52:     6 3591.318
#> 53:     7 3598.154
#> 54:    12 3558.043
#> 55:     5 3596.534
#> 56:    11 3571.354
#> 57:    33 3599.827
#> 58:    10 3575.856
#> 59:    32 3599.884
#> 60:     3 3599.515
#> 61:    84 3596.373
#> 62:    76 3596.997
#> 63:    83 3599.771
#> 64:     4 3599.290
#> 65:    80 3487.110
#> 66:    81 3479.151
#> 67:    77 3526.845
#> 68:    86 3574.734
#> 69:    91 2172.244
#> 70:    82 3599.578
#> 71:    79 3499.224
#> 72:    89 3550.060
#> 73:    87 3567.149
#> 74:    78 3510.511
#> 75:    88 3558.066
#> 76:    90 3528.552
#> 77:    85 3585.930
#> 78:     2 3599.744
#> 79:     1 3599.960
#> 80:     8 3593.580
#> 81:    30 3562.759
#> 82:    18 3571.875
#> 83:    13 3596.767
#> 84:    22 3598.693
#> 85:    19 3569.352
#> 86:    16 3586.475
#> 87:    31 3548.195
#> 88:    17 3578.853
#> 89:    23 3598.692
#> 90:    14 3598.181
#> 91:    15 3594.004
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
#>   1:      1 estimated 1105.8825     3
#>   2:      2 estimated 1089.8365     1
#>   3:      3 estimated  337.8349     7
#>   4:      4 estimated  317.7009     2
#>   5:      5 estimated  318.5449     1
#>  ---                                 
#> 446:    495 estimated  584.8126     6
#> 447:    496 estimated 1383.8231     2
#> 448:    497 estimated 1391.0735     4
#> 449:    498 estimated  617.6860     5
#> 450:    500 estimated  577.8780     2
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     3 32282.33
#>  2:     1 32227.50
#>  3:     7 32221.78
#>  4:     2 32282.03
#>  5:     6 32222.02
#>  6:     9 32297.96
#>  7:     4 32221.91
#>  8:    10 32298.53
#>  9:     5 32298.27
#> 10:     8 32221.78
```

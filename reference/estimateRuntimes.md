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
#> 499:    499    499 1789914707 1789914707 1789915207   <NA>       NA           1
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
#> 499: cfInteractive     <NA> jobbc5164144e753bcbf97212adf61e0a30     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0353 secs
#>  2:     42    iris      nrow     9      b 1100.0346 secs
#>  3:     47    iris      nrow    10      b 1100.0344 secs
#>  4:     66    iris      nrow    14      a 1100.0381 secs
#>  5:     73    iris      nrow    15      c  100.0341 secs
#>  6:     75    iris      nrow    15      e  100.0341 secs
#>  7:     86    iris      nrow    18      a 1100.0345 secs
#>  8:    100    iris      nrow    20      e  100.0341 secs
#>  9:    101    iris      nrow    21      a 1100.0340 secs
#> 10:    103    iris      nrow    21      c  100.0338 secs
#> 11:    123    iris      nrow    25      c  100.0343 secs
#> 12:    125    iris      nrow    25      e  100.0344 secs
#> 13:    161    iris      nrow    33      a 1100.0341 secs
#> 14:    165    iris      nrow    33      e  100.0343 secs
#> 15:    169    iris      nrow    34      d  100.0387 secs
#> 16:    183    iris      nrow    37      c  100.0345 secs
#> 17:    184    iris      nrow    37      d  100.0342 secs
#> 18:    203    iris      nrow    41      c  100.0345 secs
#> 19:    207    iris      nrow    42      b 1100.0346 secs
#> 20:    209    iris      nrow    42      d  100.0343 secs
#> 21:    220    iris      nrow    44      e  100.0342 secs
#> 22:    227    iris      nrow    46      b 1100.0343 secs
#> 23:    229    iris      nrow    46      d  100.0342 secs
#> 24:    231    iris      nrow    47      a 1100.0339 secs
#> 25:    244    iris      nrow    49      d  100.0339 secs
#> 26:    260    iris      ncol     2      e  500.0381 secs
#> 27:    276    iris      ncol     6      a 1500.0339 secs
#> 28:    278    iris      ncol     6      c  500.0340 secs
#> 29:    279    iris      ncol     6      d  500.0342 secs
#> 30:    296    iris      ncol    10      a 1500.0337 secs
#> 31:    320    iris      ncol    14      e  500.0373 secs
#> 32:    340    iris      ncol    18      e  500.0337 secs
#> 33:    347    iris      ncol    20      b 1500.0338 secs
#> 34:    363    iris      ncol    23      c  500.0342 secs
#> 35:    369    iris      ncol    24      d  500.0342 secs
#> 36:    373    iris      ncol    25      c  500.0389 secs
#> 37:    387    iris      ncol    28      b 1500.0337 secs
#> 38:    410    iris      ncol    32      e  500.0336 secs
#> 39:    421    iris      ncol    35      a 1500.0335 secs
#> 40:    436    iris      ncol    38      a 1500.0336 secs
#> 41:    444    iris      ncol    39      d  500.0378 secs
#> 42:    448    iris      ncol    40      c  500.0341 secs
#> 43:    456    iris      ncol    42      a 1500.0335 secs
#> 44:    459    iris      ncol    42      d  500.0337 secs
#> 45:    467    iris      ncol    44      b 1500.0382 secs
#> 46:    468    iris      ncol    44      c  500.0337 secs
#> 47:    475    iris      ncol    45      e  500.0334 secs
#> 48:    482    iris      ncol    47      b 1500.0336 secs
#> 49:    492    iris      ncol    49      b 1500.0380 secs
#> 50:    499    iris      ncol    50      d  500.0341 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.7s
#>   Remaining: 3d 17h 39m 31.8s
#>   Total    : 4d 03h 22m 53.6s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1105.8890
#>   2:      2    iris      nrow     1      b estimated 1089.8431
#>   3:      3    iris      nrow     1      c estimated  338.6413
#>   4:      4    iris      nrow     1      d estimated  319.0673
#>   5:      5    iris      nrow     1      e estimated  318.5512
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1383.8289
#> 497:    497    iris      ncol    50      b estimated 1391.0794
#> 498:    498    iris      ncol    50      c estimated  618.8918
#> 499:    499    iris      ncol    50      d  observed  500.0341
#> 500:    500    iris      ncol    50      e estimated  579.0839
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.7s
#>   Remaining: 3d 17h 39m 31.8s
#>   Parallel : 0d 08h 58m 39.0s
#>   Total    : 4d 03h 22m 53.6s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1421.1258
#>   2:    461 estimated 1419.7320
#>   3:    462 estimated 1415.9917
#>   4:    457 estimated 1415.9917
#>   5:    472 estimated 1414.9456
#>  ---                           
#> 446:    185 estimated  133.4616
#> 447:    189 estimated  132.7997
#> 448:    204 estimated  132.6492
#> 449:    174 estimated  131.3830
#> 450:    179 estimated  130.2357
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.8890    47
#>   2:      2 estimated 1089.8431    52
#>   3:      3 estimated  338.6413    54
#>   4:      4 estimated  319.0673    34
#>   5:      5 estimated  318.5512    71
#>  ---                                 
#> 446:    495 estimated  586.0185    15
#> 447:    496 estimated 1383.8289    20
#> 448:    497 estimated 1391.0794    13
#> 449:    498 estimated  618.8918     4
#> 450:    500 estimated  579.0839    19
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.8890    47
#>   2:      2 estimated 1089.8431    52
#>   3:      3 estimated  338.6413    54
#>   4:      4 estimated  319.0673    34
#>   5:      5 estimated  318.5512    71
#>  ---                                 
#> 446:    495 estimated  586.0185    15
#> 447:    496 estimated 1383.8289    20
#> 448:    497 estimated 1391.0794    13
#> 449:    498 estimated  618.8918     4
#> 450:    500 estimated  579.0839    19
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3492.736
#>  2:    52 3597.657
#>  3:    54 3591.869
#>  4:    34 3593.744
#>  5:    71 3491.653
#>  6:    48 3486.294
#>  7:    55 3586.797
#>  8:    51 3598.323
#>  9:    72 3488.819
#> 10:    56 3575.739
#> 11:    69 3494.915
#> 12:    73 3482.905
#> 13:    53 3594.762
#> 14:    57 3568.573
#> 15:    70 3493.677
#> 16:    74 3474.410
#> 17:    46 3517.016
#> 18:    50 3599.776
#> 19:    38 3596.037
#> 20:    64 3515.067
#> 21:    43 3570.706
#> 22:    65 3512.938
#> 23:    42 3580.506
#> 24:    37 3599.616
#> 25:    62 3529.755
#> 26:    40 3599.618
#> 27:    58 3554.906
#> 28:    59 3546.711
#> 29:    49 3479.577
#> 30:    39 3599.521
#> 31:    61 3535.964
#> 32:    63 3524.482
#> 33:    41 3588.027
#> 34:    60 3540.479
#> 35:    36 3599.880
#> 36:    44 3541.845
#> 37:    35 3594.514
#> 38:    67 3508.589
#> 39:    45 3541.045
#> 40:    66 3510.930
#> 41:    68 3506.801
#> 42:    28 3595.297
#> 43:    24 3599.021
#> 44:    25 3590.939
#> 45:    27 3596.849
#> 46:    23 3599.467
#> 47:    26 3588.426
#> 48:    75 3599.738
#> 49:    12 3561.386
#> 50:     9 3589.263
#> 51:    21 3518.131
#> 52:    20 3522.822
#> 53:     7 3599.924
#> 54:     6 3591.807
#> 55:     5 3596.558
#> 56:    10 3576.402
#> 57:    32 3599.628
#> 58:    11 3573.022
#> 59:    33 3599.960
#> 60:    82 3470.496
#> 61:    85 3592.228
#> 62:     4 3599.314
#> 63:     3 3599.958
#> 64:    84 3599.443
#> 65:    76 3596.764
#> 66:    80 3492.998
#> 67:    81 3480.798
#> 68:    87 3572.414
#> 69:    88 3564.355
#> 70:    91 2442.328
#> 71:    79 3503.074
#> 72:    90 3532.245
#> 73:    78 3511.813
#> 74:    89 3554.917
#> 75:    77 3533.018
#> 76:    86 3580.648
#> 77:    83 3599.010
#> 78:     2 3599.710
#> 79:     8 3594.270
#> 80:    30 3563.476
#> 81:    18 3571.392
#> 82:    13 3597.889
#> 83:    22 3599.067
#> 84:    19 3568.733
#> 85:    16 3587.117
#> 86:    31 3548.438
#> 87:    17 3578.296
#> 88:    29 3571.055
#> 89:    15 3593.624
#> 90:    14 3596.418
#> 91:     1 3470.708
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
#>   1:      1 estimated 1105.8890     7
#>   2:      2 estimated 1089.8431     1
#>   3:      3 estimated  338.6413     2
#>   4:      4 estimated  319.0673     5
#>   5:      5 estimated  318.5512     9
#>  ---                                 
#> 446:    495 estimated  586.0185     8
#> 447:    496 estimated 1383.8289     2
#> 448:    497 estimated 1391.0794     4
#> 449:    498 estimated  618.8918     6
#> 450:    500 estimated  579.0839     3
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     7 32318.95
#>  2:     1 32240.33
#>  3:     2 32240.59
#>  4:     5 32245.70
#>  5:     9 32302.71
#>  6:     6 32240.22
#>  7:     8 32318.71
#>  8:     3 32318.27
#>  9:     4 32303.28
#> 10:    10 32243.06
```

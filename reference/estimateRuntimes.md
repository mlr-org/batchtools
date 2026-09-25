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
#> 499:    499    499 1790353420 1790353421 1790353921   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job364e3ae719f917a9b686a1eaf5f21dab     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0359 secs
#>  2:     42    iris      nrow     9      b 1100.0346 secs
#>  3:     47    iris      nrow    10      b 1100.0345 secs
#>  4:     66    iris      nrow    14      a 1100.0385 secs
#>  5:     73    iris      nrow    15      c  100.0366 secs
#>  6:     75    iris      nrow    15      e  100.0356 secs
#>  7:     86    iris      nrow    18      a 1100.0352 secs
#>  8:    100    iris      nrow    20      e  100.0340 secs
#>  9:    101    iris      nrow    21      a 1100.0356 secs
#> 10:    103    iris      nrow    21      c  100.0422 secs
#> 11:    123    iris      nrow    25      c  100.0366 secs
#> 12:    125    iris      nrow    25      e  100.0368 secs
#> 13:    161    iris      nrow    33      a 1100.0355 secs
#> 14:    165    iris      nrow    33      e  100.0342 secs
#> 15:    169    iris      nrow    34      d  100.0396 secs
#> 16:    183    iris      nrow    37      c  100.0369 secs
#> 17:    184    iris      nrow    37      d  100.0372 secs
#> 18:    203    iris      nrow    41      c  100.0354 secs
#> 19:    207    iris      nrow    42      b 1100.0347 secs
#> 20:    209    iris      nrow    42      d  100.0405 secs
#> 21:    220    iris      nrow    44      e  100.0366 secs
#> 22:    227    iris      nrow    46      b 1100.0378 secs
#> 23:    229    iris      nrow    46      d  100.0360 secs
#> 24:    231    iris      nrow    47      a 1100.0352 secs
#> 25:    244    iris      nrow    49      d  100.0391 secs
#> 26:    260    iris      ncol     2      e  500.0362 secs
#> 27:    276    iris      ncol     6      a 1500.0371 secs
#> 28:    278    iris      ncol     6      c  500.0354 secs
#> 29:    279    iris      ncol     6      d  500.0347 secs
#> 30:    296    iris      ncol    10      a 1500.0361 secs
#> 31:    320    iris      ncol    14      e  500.0371 secs
#> 32:    340    iris      ncol    18      e  500.0356 secs
#> 33:    347    iris      ncol    20      b 1500.0349 secs
#> 34:    363    iris      ncol    23      c  500.0402 secs
#> 35:    369    iris      ncol    24      d  500.0362 secs
#> 36:    373    iris      ncol    25      c  500.0374 secs
#> 37:    387    iris      ncol    28      b 1500.0357 secs
#> 38:    410    iris      ncol    32      e  500.0400 secs
#> 39:    421    iris      ncol    35      a 1500.0364 secs
#> 40:    436    iris      ncol    38      a 1500.0366 secs
#> 41:    444    iris      ncol    39      d  500.0356 secs
#> 42:    448    iris      ncol    40      c  500.0394 secs
#> 43:    456    iris      ncol    42      a 1500.0361 secs
#> 44:    459    iris      ncol    42      d  500.0372 secs
#> 45:    467    iris      ncol    44      b 1500.0351 secs
#> 46:    468    iris      ncol    44      c  500.1411 secs
#> 47:    475    iris      ncol    45      e  500.0348 secs
#> 48:    482    iris      ncol    47      b 1500.0350 secs
#> 49:    492    iris      ncol    49      b 1500.0343 secs
#> 50:    499    iris      ncol    50      d  500.0335 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.9s
#>   Remaining: 3d 17h 36m 39.1s
#>   Total    : 4d 03h 20m 1.1s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1107.0898
#>   2:      2    iris      nrow     1      b estimated 1090.8837
#>   3:      3    iris      nrow     1      c estimated  337.2835
#>   4:      4    iris      nrow     1      d estimated  318.6692
#>   5:      5    iris      nrow     1      e estimated  317.1123
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1381.8749
#> 497:    497    iris      ncol    50      b estimated 1388.5641
#> 498:    498    iris      ncol    50      c estimated  613.6800
#> 499:    499    iris      ncol    50      d  observed  500.0335
#> 500:    500    iris      ncol    50      e estimated  574.1530
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.9s
#>   Remaining: 3d 17h 36m 39.1s
#>   Parallel : 0d 08h 58m 21.4s
#>   Total    : 4d 03h 20m 1.1s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1423.2527
#>   2:    461 estimated 1419.8595
#>   3:    462 estimated 1416.8723
#>   4:    457 estimated 1416.0722
#>   5:    472 estimated 1416.0255
#>  ---                           
#> 446:    164 estimated  133.4750
#> 447:    185 estimated  132.9368
#> 448:    204 estimated  131.5240
#> 449:    174 estimated  131.1253
#> 450:    179 estimated  129.9785
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1107.0898    47
#>   2:      2 estimated 1090.8837    51
#>   3:      3 estimated  337.2835    54
#>   4:      4 estimated  318.6692    32
#>   5:      5 estimated  317.1123    69
#>  ---                                 
#> 446:    495 estimated  581.0882    18
#> 447:    496 estimated 1381.8749    21
#> 448:    497 estimated 1388.5641    17
#> 449:    498 estimated  613.6800     4
#> 450:    500 estimated  574.1530    26
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1107.0898    47
#>   2:      2 estimated 1090.8837    51
#>   3:      3 estimated  337.2835    54
#>   4:      4 estimated  318.6692    32
#>   5:      5 estimated  317.1123    69
#>  ---                                 
#> 446:    495 estimated  581.0882    18
#> 447:    496 estimated 1381.8749    21
#> 448:    497 estimated 1388.5641    17
#> 449:    498 estimated  613.6800     4
#> 450:    500 estimated  574.1530    26
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3493.720
#>  2:    51 3595.357
#>  3:    54 3587.842
#>  4:    32 3598.779
#>  5:    69 3493.744
#>  6:    55 3585.836
#>  7:    33 3596.680
#>  8:    70 3491.158
#>  9:    48 3491.305
#> 10:    52 3599.080
#> 11:    56 3574.113
#> 12:    71 3488.302
#> 13:    57 3566.131
#> 14:    68 3497.664
#> 15:    72 3485.420
#> 16:    46 3519.297
#> 17:    50 3599.364
#> 18:    38 3594.978
#> 19:    62 3523.902
#> 20:    65 3514.996
#> 21:    43 3565.339
#> 22:    63 3522.365
#> 23:    66 3509.405
#> 24:    42 3575.539
#> 25:    35 3599.471
#> 26:    61 3530.973
#> 27:    53 3598.382
#> 28:    39 3596.834
#> 29:    37 3598.059
#> 30:    58 3555.595
#> 31:    49 3485.393
#> 32:    41 3584.571
#> 33:    59 3547.990
#> 34:    60 3534.473
#> 35:    40 3592.171
#> 36:    36 3599.882
#> 37:    44 3535.416
#> 38:    64 3518.302
#> 39:    45 3534.616
#> 40:    34 3599.566
#> 41:    67 3506.352
#> 42:    27 3598.220
#> 43:    25 3592.267
#> 44:    24 3598.877
#> 45:    26 3596.813
#> 46:    23 3599.946
#> 47:    28 3570.864
#> 48:    75 3599.417
#> 49:    12 3564.540
#> 50:    74 3598.713
#> 51:    10 3582.930
#> 52:    20 3523.560
#> 53:    31 3599.735
#> 54:     9 3592.039
#> 55:     5 3598.822
#> 56:     6 3596.082
#> 57:    11 3576.360
#> 58:     7 3597.267
#> 59:     4 3597.587
#> 60:     3 3599.942
#> 61:     2 3599.911
#> 62:    82 3599.587
#> 63:    73 3487.475
#> 64:    81 3474.322
#> 65:    79 3494.732
#> 66:    76 3588.637
#> 67:    85 3581.728
#> 68:    89 3551.946
#> 69:    91 1898.475
#> 70:    80 3482.483
#> 71:    77 3521.203
#> 72:    87 3566.602
#> 73:    88 3558.545
#> 74:    86 3574.205
#> 75:    84 3588.058
#> 76:    78 3502.558
#> 77:    83 3596.275
#> 78:    90 3529.819
#> 79:     1 3599.276
#> 80:     8 3599.943
#> 81:    22 3597.610
#> 82:    18 3577.634
#> 83:    13 3599.447
#> 84:    30 3555.905
#> 85:    19 3571.599
#> 86:    16 3586.856
#> 87:    21 3599.970
#> 88:    17 3582.946
#> 89:    29 3564.371
#> 90:    15 3594.816
#> 91:    14 3599.860
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
#>   1:      1 estimated 1107.0898     6
#>   2:      2 estimated 1090.8837     8
#>   3:      3 estimated  337.2835     6
#>   4:      4 estimated  318.6692    10
#>   5:      5 estimated  317.1123     2
#>  ---                                 
#> 446:    495 estimated  581.0882     8
#> 447:    496 estimated 1381.8749     4
#> 448:    497 estimated 1388.5641    10
#> 449:    498 estimated  613.6800     3
#> 450:    500 estimated  574.1530     7
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     6 32222.75
#>  2:     8 32222.59
#>  3:    10 32228.14
#>  4:     2 32288.02
#>  5:     9 32301.26
#>  6:     5 32301.43
#>  7:     7 32222.93
#>  8:     4 32288.24
#>  9:     1 32300.55
#> 10:     3 32223.22
```

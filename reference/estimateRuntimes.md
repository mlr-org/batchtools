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
#> 499:    499    499 1790791788 1790791788 1790792288   <NA>       NA           1
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
#> 499: cfInteractive     <NA> jobd662c7207bb0b4beb653337a3c7943e5     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0362 secs
#>  2:     42    iris      nrow     9      b 1100.0406 secs
#>  3:     47    iris      nrow    10      b 1100.0361 secs
#>  4:     66    iris      nrow    14      a 1100.0362 secs
#>  5:     73    iris      nrow    15      c  100.0354 secs
#>  6:     75    iris      nrow    15      e  100.0350 secs
#>  7:     86    iris      nrow    18      a 1100.0347 secs
#>  8:    100    iris      nrow    20      e  100.0370 secs
#>  9:    101    iris      nrow    21      a 1100.0360 secs
#> 10:    103    iris      nrow    21      c  100.0354 secs
#> 11:    123    iris      nrow    25      c  100.0350 secs
#> 12:    125    iris      nrow    25      e  100.0351 secs
#> 13:    161    iris      nrow    33      a 1100.0392 secs
#> 14:    165    iris      nrow    33      e  100.0372 secs
#> 15:    169    iris      nrow    34      d  100.0366 secs
#> 16:    183    iris      nrow    37      c  100.0354 secs
#> 17:    184    iris      nrow    37      d  100.0348 secs
#> 18:    203    iris      nrow    41      c  100.0351 secs
#> 19:    207    iris      nrow    42      b 1100.0368 secs
#> 20:    209    iris      nrow    42      d  100.0365 secs
#> 21:    220    iris      nrow    44      e  100.0355 secs
#> 22:    227    iris      nrow    46      b 1100.0348 secs
#> 23:    229    iris      nrow    46      d  100.0354 secs
#> 24:    231    iris      nrow    47      a 1100.0403 secs
#> 25:    244    iris      nrow    49      d  100.0364 secs
#> 26:    260    iris      ncol     2      e  500.0367 secs
#> 27:    276    iris      ncol     6      a 1500.0349 secs
#> 28:    278    iris      ncol     6      c  500.0347 secs
#> 29:    279    iris      ncol     6      d  500.0395 secs
#> 30:    296    iris      ncol    10      a 1500.0364 secs
#> 31:    320    iris      ncol    14      e  500.0364 secs
#> 32:    340    iris      ncol    18      e  500.0351 secs
#> 33:    347    iris      ncol    20      b 1500.0346 secs
#> 34:    363    iris      ncol    23      c  500.0396 secs
#> 35:    369    iris      ncol    24      d  500.0362 secs
#> 36:    373    iris      ncol    25      c  500.0366 secs
#> 37:    387    iris      ncol    28      b 1500.0355 secs
#> 38:    410    iris      ncol    32      e  500.0354 secs
#> 39:    421    iris      ncol    35      a 1500.0405 secs
#> 40:    436    iris      ncol    38      a 1500.0369 secs
#> 41:    444    iris      ncol    39      d  500.0355 secs
#> 42:    448    iris      ncol    40      c  500.0352 secs
#> 43:    456    iris      ncol    42      a 1500.0398 secs
#> 44:    459    iris      ncol    42      d  500.0360 secs
#> 45:    467    iris      ncol    44      b 1500.0359 secs
#> 46:    468    iris      ncol    44      c  500.0347 secs
#> 47:    475    iris      ncol    45      e  500.0386 secs
#> 48:    482    iris      ncol    47      b 1500.0362 secs
#> 49:    492    iris      ncol    49      b 1500.0358 secs
#> 50:    499    iris      ncol    50      d  500.0349 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.8s
#>   Remaining: 3d 17h 38m 25.3s
#>   Total    : 4d 03h 21m 47.1s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1106.0508
#>   2:      2    iris      nrow     1      b estimated 1090.0052
#>   3:      3    iris      nrow     1      c estimated  338.7626
#>   4:      4    iris      nrow     1      d estimated  319.8686
#>   5:      5    iris      nrow     1      e estimated  319.0859
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1382.0762
#> 497:    497    iris      ncol    50      b estimated 1389.1248
#> 498:    498    iris      ncol    50      c estimated  615.8183
#> 499:    499    iris      ncol    50      d  observed  500.0349
#> 500:    500    iris      ncol    50      e estimated  576.8107
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.8s
#>   Remaining: 3d 17h 38m 25.3s
#>   Parallel : 0d 08h 58m 30.9s
#>   Total    : 4d 03h 21m 47.1s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1421.4537
#>   2:    461 estimated 1420.0605
#>   3:    462 estimated 1416.1184
#>   4:    457 estimated 1415.3184
#>   5:    487 estimated 1414.6437
#>  ---                           
#> 446:    164 estimated  133.4735
#> 447:    185 estimated  132.8029
#> 448:    174 estimated  131.1235
#> 449:    204 estimated  130.9618
#> 450:    179 estimated  129.9765
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0508    47
#>   2:      2 estimated 1090.0052    52
#>   3:      3 estimated  338.7626    55
#>   4:      4 estimated  319.8686    34
#>   5:      5 estimated  319.0859    71
#>  ---                                 
#> 446:    495 estimated  582.9454    15
#> 447:    496 estimated 1382.0762    21
#> 448:    497 estimated 1389.1248    15
#> 449:    498 estimated  615.8183     4
#> 450:    500 estimated  576.8107    22
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0508    47
#>   2:      2 estimated 1090.0052    52
#>   3:      3 estimated  338.7626    55
#>   4:      4 estimated  319.8686    34
#>   5:      5 estimated  319.0859    71
#>  ---                                 
#> 446:    495 estimated  582.9454    15
#> 447:    496 estimated 1382.0762    21
#> 448:    497 estimated 1389.1248    15
#> 449:    498 estimated  615.8183     4
#> 450:    500 estimated  576.8107    22
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3492.796
#>  2:    52 3598.167
#>  3:    55 3585.343
#>  4:    34 3596.510
#>  5:    71 3488.236
#>  6:    48 3487.557
#>  7:    56 3575.072
#>  8:    51 3596.891
#>  9:    72 3485.934
#> 10:    57 3566.331
#> 11:    69 3493.997
#> 12:    73 3478.845
#> 13:    53 3595.095
#> 14:    58 3554.319
#> 15:    70 3491.914
#> 16:    74 3599.130
#> 17:    46 3517.237
#> 18:    50 3599.062
#> 19:    38 3599.484
#> 20:    36 3595.920
#> 21:    39 3595.017
#> 22:    37 3595.103
#> 23:    66 3508.631
#> 24:    43 3579.805
#> 25:    62 3530.249
#> 26:    64 3524.940
#> 27:    41 3590.205
#> 28:    54 3591.213
#> 29:    59 3545.304
#> 30:    49 3479.024
#> 31:    42 3585.228
#> 32:    61 3533.920
#> 33:    65 3520.319
#> 34:    40 3599.838
#> 35:    60 3536.589
#> 36:    63 3527.188
#> 37:    44 3546.290
#> 38:    35 3596.926
#> 39:    67 3507.222
#> 40:    45 3545.490
#> 41:    68 3503.427
#> 42:    28 3596.510
#> 43:    25 3594.054
#> 44:    26 3591.662
#> 45:    27 3598.157
#> 46:    29 3572.663
#> 47:    24 3598.975
#> 48:    75 3599.900
#> 49:    12 3564.346
#> 50:     9 3588.773
#> 51:    20 3521.372
#> 52:    21 3518.103
#> 53:     8 3593.085
#> 54:     5 3593.543
#> 55:    11 3566.287
#> 56:     6 3598.983
#> 57:    32 3599.974
#> 58:    10 3580.176
#> 59:    33 3599.886
#> 60:     4 3597.845
#> 61:    81 3477.755
#> 62:    83 3599.635
#> 63:    84 3592.346
#> 64:    76 3598.784
#> 65:     2 3599.525
#> 66:    79 3499.671
#> 67:    77 3523.192
#> 68:    86 3575.501
#> 69:    88 3554.384
#> 70:    91 2033.267
#> 71:    82 3599.360
#> 72:    89 3545.053
#> 73:    78 3508.661
#> 74:    87 3565.751
#> 75:    85 3582.200
#> 76:    90 3518.809
#> 77:    80 3489.299
#> 78:     3 3599.777
#> 79:     1 3598.615
#> 80:     7 3595.665
#> 81:    23 3596.052
#> 82:    18 3577.362
#> 83:    14 3596.587
#> 84:    22 3597.650
#> 85:    19 3570.792
#> 86:    13 3599.418
#> 87:    31 3551.951
#> 88:    17 3582.541
#> 89:    30 3571.031
#> 90:    16 3594.260
#> 91:    15 3596.339
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
#>   1:      1 estimated 1106.0508     1
#>   2:      2 estimated 1090.0052     2
#>   3:      3 estimated  338.7626     5
#>   4:      4 estimated  319.8686     4
#>   5:      5 estimated  319.0859     7
#>  ---                                 
#> 446:    495 estimated  582.9454    10
#> 447:    496 estimated 1382.0762     3
#> 448:    497 estimated 1389.1248     1
#> 449:    498 estimated  615.8183     6
#> 450:    500 estimated  576.8107     4
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     1 32310.87
#>  2:     2 32310.75
#>  3:     5 32235.53
#>  4:     4 32240.74
#>  5:     7 32296.33
#>  6:     6 32235.29
#>  7:     8 32295.74
#>  8:     9 32234.74
#>  9:    10 32310.51
#> 10:     3 32234.80
```

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
#> 499:    499    499 1790791998 1790791998 1790792498   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job53359ae3bf5934d4cfd8f49d75793187     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0351 secs
#>  2:     42    iris      nrow     9      b 1100.0396 secs
#>  3:     47    iris      nrow    10      b 1100.0358 secs
#>  4:     66    iris      nrow    14      a 1100.0355 secs
#>  5:     73    iris      nrow    15      c  100.0334 secs
#>  6:     75    iris      nrow    15      e  100.0347 secs
#>  7:     86    iris      nrow    18      a 1100.0338 secs
#>  8:    100    iris      nrow    20      e  100.0351 secs
#>  9:    101    iris      nrow    21      a 1100.0364 secs
#> 10:    103    iris      nrow    21      c  100.0353 secs
#> 11:    123    iris      nrow    25      c  100.0336 secs
#> 12:    125    iris      nrow    25      e  100.0343 secs
#> 13:    161    iris      nrow    33      a 1100.0387 secs
#> 14:    165    iris      nrow    33      e  100.0364 secs
#> 15:    169    iris      nrow    34      d  100.0356 secs
#> 16:    183    iris      nrow    37      c  100.0339 secs
#> 17:    184    iris      nrow    37      d  100.0342 secs
#> 18:    203    iris      nrow    41      c  100.0342 secs
#> 19:    207    iris      nrow    42      b 1100.0364 secs
#> 20:    209    iris      nrow    42      d  100.0358 secs
#> 21:    220    iris      nrow    44      e  100.0354 secs
#> 22:    227    iris      nrow    46      b 1100.0344 secs
#> 23:    229    iris      nrow    46      d  100.0345 secs
#> 24:    231    iris      nrow    47      a 1100.0404 secs
#> 25:    244    iris      nrow    49      d  100.0364 secs
#> 26:    260    iris      ncol     2      e  500.0365 secs
#> 27:    276    iris      ncol     6      a 1500.0347 secs
#> 28:    278    iris      ncol     6      c  500.0344 secs
#> 29:    279    iris      ncol     6      d  500.0392 secs
#> 30:    296    iris      ncol    10      a 1500.0366 secs
#> 31:    320    iris      ncol    14      e  500.0370 secs
#> 32:    340    iris      ncol    18      e  500.0341 secs
#> 33:    347    iris      ncol    20      b 1500.0341 secs
#> 34:    363    iris      ncol    23      c  500.0396 secs
#> 35:    369    iris      ncol    24      d  500.0355 secs
#> 36:    373    iris      ncol    25      c  500.0361 secs
#> 37:    387    iris      ncol    28      b 1500.0345 secs
#> 38:    410    iris      ncol    32      e  500.0345 secs
#> 39:    421    iris      ncol    35      a 1500.0404 secs
#> 40:    436    iris      ncol    38      a 1500.0361 secs
#> 41:    444    iris      ncol    39      d  500.0343 secs
#> 42:    448    iris      ncol    40      c  500.0342 secs
#> 43:    456    iris      ncol    42      a 1500.0400 secs
#> 44:    459    iris      ncol    42      d  500.0356 secs
#> 45:    467    iris      ncol    44      b 1500.0356 secs
#> 46:    468    iris      ncol    44      c  500.0342 secs
#> 47:    475    iris      ncol    45      e  500.0392 secs
#> 48:    482    iris      ncol    47      b 1500.0357 secs
#> 49:    492    iris      ncol    49      b 1500.0352 secs
#> 50:    499    iris      ncol    50      d  500.0343 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.8s
#>   Remaining: 3d 17h 38m 33.0s
#>   Total    : 4d 03h 21m 54.8s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1106.0502
#>   2:      2    iris      nrow     1      b estimated 1089.8445
#>   3:      3    iris      nrow     1      c estimated  338.7617
#>   4:      4    iris      nrow     1      d estimated  319.6011
#>   5:      5    iris      nrow     1      e estimated  319.0852
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1382.9509
#> 497:    497    iris      ncol    50      b estimated 1389.9994
#> 498:    498    iris      ncol    50      c estimated  616.8929
#> 499:    499    iris      ncol    50      d  observed  500.0343
#> 500:    500    iris      ncol    50      e estimated  577.8855
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.8s
#>   Remaining: 3d 17h 38m 33.0s
#>   Parallel : 0d 08h 58m 31.8s
#>   Total    : 4d 03h 21m 54.8s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1420.3284
#>   2:    461 estimated 1418.9352
#>   3:    462 estimated 1414.9929
#>   4:    457 estimated 1414.1929
#>   5:    487 estimated 1413.5183
#>  ---                           
#> 446:    185 estimated  132.9621
#> 447:    194 estimated  132.8713
#> 448:    174 estimated  130.8826
#> 449:    204 estimated  130.5211
#> 450:    179 estimated  129.7357
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0502    47
#>   2:      2 estimated 1089.8445    52
#>   3:      3 estimated  338.7617    54
#>   4:      4 estimated  319.6011    34
#>   5:      5 estimated  319.0852    71
#>  ---                                 
#> 446:    495 estimated  584.8201    15
#> 447:    496 estimated 1382.9509    20
#> 448:    497 estimated 1389.9994    14
#> 449:    498 estimated  616.8929     4
#> 450:    500 estimated  577.8855    21
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0502    47
#>   2:      2 estimated 1089.8445    52
#>   3:      3 estimated  338.7617    54
#>   4:      4 estimated  319.6011    34
#>   5:      5 estimated  319.0852    71
#>  ---                                 
#> 446:    495 estimated  584.8201    15
#> 447:    496 estimated 1382.9509    20
#> 448:    497 estimated 1389.9994    14
#> 449:    498 estimated  616.8929     4
#> 450:    500 estimated  577.8855    21
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3493.594
#>  2:    52 3598.195
#>  3:    54 3590.862
#>  4:    34 3594.242
#>  5:    71 3488.394
#>  6:    48 3487.554
#>  7:    55 3585.341
#>  8:    51 3596.623
#>  9:    72 3486.092
#> 10:    56 3575.070
#> 11:    69 3493.728
#> 12:    73 3479.323
#> 13:    53 3594.772
#> 14:    57 3566.329
#> 15:    70 3491.965
#> 16:    74 3599.367
#> 17:    46 3518.034
#> 18:    50 3599.793
#> 19:    38 3596.682
#> 20:    36 3593.675
#> 21:    39 3594.504
#> 22:    65 3513.254
#> 23:    43 3577.883
#> 24:    61 3532.548
#> 25:    63 3526.883
#> 26:    41 3588.043
#> 27:    58 3554.080
#> 28:    59 3545.302
#> 29:    49 3479.022
#> 30:    42 3583.306
#> 31:    60 3535.601
#> 32:    64 3524.681
#> 33:    40 3599.463
#> 34:    37 3599.801
#> 35:    62 3529.767
#> 36:    44 3544.102
#> 37:    35 3596.065
#> 38:    67 3507.236
#> 39:    45 3543.302
#> 40:    66 3508.368
#> 41:    68 3503.568
#> 42:    28 3595.501
#> 43:    25 3593.287
#> 44:    24 3599.976
#> 45:    27 3597.825
#> 46:    29 3572.240
#> 47:    26 3589.900
#> 48:    75 3598.856
#> 49:    12 3563.902
#> 50:     9 3586.962
#> 51:    21 3517.014
#> 52:    20 3521.420
#> 53:     8 3590.833
#> 54:    11 3566.070
#> 55:    10 3571.886
#> 56:     6 3596.731
#> 57:    33 3599.938
#> 58:     5 3599.336
#> 59:    32 3599.946
#> 60:     4 3596.668
#> 61:    81 3483.884
#> 62:    83 3599.372
#> 63:    76 3598.789
#> 64:     2 3599.948
#> 65:    79 3504.243
#> 66:     3 3599.733
#> 67:    77 3528.459
#> 68:    87 3568.754
#> 69:    91 2160.163
#> 70:    82 3473.099
#> 71:    89 3552.889
#> 72:    78 3514.883
#> 73:    88 3561.458
#> 74:    85 3588.186
#> 75:    90 3522.728
#> 76:    84 3596.489
#> 77:    80 3493.953
#> 78:    86 3579.398
#> 79:     1 3599.947
#> 80:     7 3593.413
#> 81:    23 3595.458
#> 82:    18 3574.844
#> 83:    13 3599.443
#> 84:    22 3598.673
#> 85:    19 3568.274
#> 86:    16 3588.347
#> 87:    31 3548.229
#> 88:    17 3580.490
#> 89:    30 3567.283
#> 90:    14 3599.781
#> 91:    15 3597.649
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
#>   1:      1 estimated 1106.0502     3
#>   2:      2 estimated 1089.8445     9
#>   3:      3 estimated  338.7617     5
#>   4:      4 estimated  319.6011     3
#>   5:      5 estimated  319.0852     9
#>  ---                                 
#> 446:    495 estimated  584.8201     3
#> 447:    496 estimated 1382.9509     7
#> 448:    497 estimated 1389.9994     3
#> 449:    498 estimated  616.8929     7
#> 450:    500 estimated  577.8855     3
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     3 32240.39
#>  2:     9 32298.16
#>  3:     5 32235.21
#>  4:     1 32311.50
#>  5:     6 32298.04
#>  6:     4 32235.99
#>  7:     8 32235.89
#>  8:    10 32311.79
#>  9:     2 32311.50
#> 10:     7 32234.49
```

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
#> 499:    499    499 1790353209 1790353209 1790353709   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job7a627fe908c31aaec565d41708f6425f     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0350 secs
#>  2:     42    iris      nrow     9      b 1100.0339 secs
#>  3:     47    iris      nrow    10      b 1100.0337 secs
#>  4:     66    iris      nrow    14      a 1100.0379 secs
#>  5:     73    iris      nrow    15      c  100.0360 secs
#>  6:     75    iris      nrow    15      e  100.0351 secs
#>  7:     86    iris      nrow    18      a 1100.0348 secs
#>  8:    100    iris      nrow    20      e  100.0335 secs
#>  9:    101    iris      nrow    21      a 1100.0338 secs
#> 10:    103    iris      nrow    21      c  100.0406 secs
#> 11:    123    iris      nrow    25      c  100.0348 secs
#> 12:    125    iris      nrow    25      e  100.0353 secs
#> 13:    161    iris      nrow    33      a 1100.0338 secs
#> 14:    165    iris      nrow    33      e  100.0331 secs
#> 15:    169    iris      nrow    34      d  100.0383 secs
#> 16:    183    iris      nrow    37      c  100.0347 secs
#> 17:    184    iris      nrow    37      d  100.0364 secs
#> 18:    203    iris      nrow    41      c  100.0343 secs
#> 19:    207    iris      nrow    42      b 1100.0335 secs
#> 20:    209    iris      nrow    42      d  100.0375 secs
#> 21:    220    iris      nrow    44      e  100.0348 secs
#> 22:    227    iris      nrow    46      b 1100.0353 secs
#> 23:    229    iris      nrow    46      d  100.0341 secs
#> 24:    231    iris      nrow    47      a 1100.0333 secs
#> 25:    244    iris      nrow    49      d  100.0391 secs
#> 26:    260    iris      ncol     2      e  500.0354 secs
#> 27:    276    iris      ncol     6      a 1500.0359 secs
#> 28:    278    iris      ncol     6      c  500.0359 secs
#> 29:    279    iris      ncol     6      d  500.0334 secs
#> 30:    296    iris      ncol    10      a 1500.0354 secs
#> 31:    320    iris      ncol    14      e  500.0357 secs
#> 32:    340    iris      ncol    18      e  500.0341 secs
#> 33:    347    iris      ncol    20      b 1500.0335 secs
#> 34:    363    iris      ncol    23      c  500.0390 secs
#> 35:    369    iris      ncol    24      d  500.0347 secs
#> 36:    373    iris      ncol    25      c  500.0351 secs
#> 37:    387    iris      ncol    28      b 1500.0337 secs
#> 38:    410    iris      ncol    32      e  500.0381 secs
#> 39:    421    iris      ncol    35      a 1500.0348 secs
#> 40:    436    iris      ncol    38      a 1500.0354 secs
#> 41:    444    iris      ncol    39      d  500.0339 secs
#> 42:    448    iris      ncol    40      c  500.0380 secs
#> 43:    456    iris      ncol    42      a 1500.0348 secs
#> 44:    459    iris      ncol    42      d  500.0351 secs
#> 45:    467    iris      ncol    44      b 1500.0340 secs
#> 46:    468    iris      ncol    44      c  500.1403 secs
#> 47:    475    iris      ncol    45      e  500.0336 secs
#> 48:    482    iris      ncol    47      b 1500.0336 secs
#> 49:    492    iris      ncol    49      b 1500.0336 secs
#> 50:    499    iris      ncol    50      d  500.0333 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.9s
#>   Remaining: 3d 17h 37m 49.1s
#>   Total    : 4d 03h 21m 11.0s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1107.0889
#>   2:      2    iris      nrow     1      b estimated 1090.8828
#>   3:      3    iris      nrow     1      c estimated  337.4027
#>   4:      4    iris      nrow     1      d estimated  319.2016
#>   5:      5    iris      nrow     1      e estimated  317.6448
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1381.0738
#> 497:    497    iris      ncol    50      b estimated 1388.1230
#> 498:    498    iris      ncol    50      c estimated  613.6788
#> 499:    499    iris      ncol    50      d  observed  500.0333
#> 500:    500    iris      ncol    50      e estimated  574.9520
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.9s
#>   Remaining: 3d 17h 37m 49.1s
#>   Parallel : 0d 08h 58m 25.2s
#>   Total    : 4d 03h 21m 11.0s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1423.2515
#>   2:    461 estimated 1419.8582
#>   3:    462 estimated 1416.8709
#>   4:    472 estimated 1416.5842
#>   5:    457 estimated 1416.0708
#>  ---                           
#> 446:    164 estimated  133.4736
#> 447:    185 estimated  132.9355
#> 448:    204 estimated  131.5223
#> 449:    174 estimated  131.1238
#> 450:    179 estimated  129.9770
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1107.0889    47
#>   2:      2 estimated 1090.8828    51
#>   3:      3 estimated  337.4027    54
#>   4:      4 estimated  319.2016    33
#>   5:      5 estimated  317.6448    70
#>  ---                                 
#> 446:    495 estimated  581.8874    16
#> 447:    496 estimated 1381.0738    21
#> 448:    497 estimated 1388.1230    17
#> 449:    498 estimated  613.6788     4
#> 450:    500 estimated  574.9520    26
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1107.0889    47
#>   2:      2 estimated 1090.8828    51
#>   3:      3 estimated  337.4027    54
#>   4:      4 estimated  319.2016    33
#>   5:      5 estimated  317.6448    70
#>  ---                                 
#> 446:    495 estimated  581.8874    16
#> 447:    496 estimated 1381.0738    21
#> 448:    497 estimated 1388.1230    17
#> 449:    498 estimated  613.6788     4
#> 450:    500 estimated  574.9520    26
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3493.181
#>  2:    51 3596.246
#>  3:    54 3587.957
#>  4:    33 3597.330
#>  5:    70 3494.617
#>  6:    55 3585.952
#>  7:    71 3492.421
#>  8:    48 3491.834
#>  9:    52 3599.969
#> 10:    56 3574.787
#> 11:    68 3500.017
#> 12:    72 3489.182
#> 13:    57 3568.646
#> 14:    69 3499.346
#> 15:    73 3483.899
#> 16:    46 3519.826
#> 17:    50 3599.281
#> 18:    38 3597.654
#> 19:    62 3524.497
#> 20:    65 3514.404
#> 21:    39 3594.407
#> 22:    63 3522.333
#> 23:    66 3512.990
#> 24:    43 3576.508
#> 25:    35 3599.734
#> 26:    61 3534.097
#> 27:    53 3599.270
#> 28:    40 3595.727
#> 29:    37 3598.321
#> 30:    58 3556.123
#> 31:    49 3483.103
#> 32:    42 3582.185
#> 33:    59 3547.958
#> 34:    60 3537.218
#> 35:    41 3584.966
#> 36:    36 3599.784
#> 37:    44 3540.865
#> 38:    34 3599.592
#> 39:    45 3540.065
#> 40:    64 3517.774
#> 41:    67 3508.850
#> 42:    27 3597.518
#> 43:    24 3599.442
#> 44:    25 3589.985
#> 45:    26 3597.719
#> 46:    23 3599.648
#> 47:    28 3573.351
#> 48:    74 3477.541
#> 49:    75 3599.622
#> 50:    12 3565.069
#> 51:     8 3597.632
#> 52:    20 3524.049
#> 53:    31 3599.860
#> 54:     7 3598.893
#> 55:     5 3598.493
#> 56:     6 3593.709
#> 57:    11 3575.965
#> 58:    10 3578.182
#> 59:    32 3599.723
#> 60:     4 3597.702
#> 61:    80 3484.316
#> 62:    82 3599.783
#> 63:    83 3599.935
#> 64:    77 3522.818
#> 65:    79 3498.855
#> 66:    76 3591.753
#> 67:    85 3584.021
#> 68:    87 3566.701
#> 69:    91 2030.654
#> 70:    81 3477.500
#> 71:    78 3506.346
#> 72:    88 3558.117
#> 73:    89 3552.089
#> 74:    84 3593.474
#> 75:    90 3528.195
#> 76:    86 3575.800
#> 77:     2 3599.058
#> 78:     1 3599.271
#> 79:     3 3599.470
#> 80:     9 3589.803
#> 81:    29 3557.717
#> 82:    18 3575.959
#> 83:    13 3596.333
#> 84:    21 3598.886
#> 85:    19 3569.887
#> 86:    16 3584.532
#> 87:    30 3550.291
#> 88:    17 3580.477
#> 89:    22 3599.496
#> 90:    14 3598.523
#> 91:    15 3592.025
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
#>   1:      1 estimated 1107.0889     4
#>   2:      2 estimated 1090.8828     2
#>   3:      3 estimated  337.4027    10
#>   4:      4 estimated  319.2016     9
#>   5:      5 estimated  317.6448     4
#>  ---                                 
#> 446:    495 estimated  581.8874     9
#> 447:    496 estimated 1381.0738     4
#> 448:    497 estimated 1388.1230     5
#> 449:    498 estimated  613.6788     5
#> 450:    500 estimated  574.9520     9
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     4 32298.47
#>  2:     2 32304.78
#>  3:    10 32230.86
#>  4:     9 32234.96
#>  5:     7 32304.46
#>  6:     5 32231.12
#>  7:     1 32298.04
#>  8:     3 32230.81
#>  9:     8 32305.23
#> 10:     6 32230.39
```

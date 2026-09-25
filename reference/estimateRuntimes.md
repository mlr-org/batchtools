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
#> 499:    499    499 1790353631 1790353631 1790354131   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job6a80e68a3f7e100a59d33bb13f728f64     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0285 secs
#>  2:     42    iris      nrow     9      b 1100.0329 secs
#>  3:     47    iris      nrow    10      b 1100.0283 secs
#>  4:     66    iris      nrow    14      a 1100.0285 secs
#>  5:     73    iris      nrow    15      c  100.0262 secs
#>  6:     75    iris      nrow    15      e  100.0263 secs
#>  7:     86    iris      nrow    18      a 1100.0263 secs
#>  8:    100    iris      nrow    20      e  100.0291 secs
#>  9:    101    iris      nrow    21      a 1100.0278 secs
#> 10:    103    iris      nrow    21      c  100.0272 secs
#> 11:    123    iris      nrow    25      c  100.0261 secs
#> 12:    125    iris      nrow    25      e  100.0260 secs
#> 13:    161    iris      nrow    33      a 1100.0304 secs
#> 14:    165    iris      nrow    33      e  100.0291 secs
#> 15:    169    iris      nrow    34      d  100.0289 secs
#> 16:    183    iris      nrow    37      c  100.0262 secs
#> 17:    184    iris      nrow    37      d  100.0260 secs
#> 18:    203    iris      nrow    41      c  100.0260 secs
#> 19:    207    iris      nrow    42      b 1100.0288 secs
#> 20:    209    iris      nrow    42      d  100.0278 secs
#> 21:    220    iris      nrow    44      e  100.0279 secs
#> 22:    227    iris      nrow    46      b 1100.0264 secs
#> 23:    229    iris      nrow    46      d  100.0261 secs
#> 24:    231    iris      nrow    47      a 1100.0322 secs
#> 25:    244    iris      nrow    49      d  100.0281 secs
#> 26:    260    iris      ncol     2      e  500.0285 secs
#> 27:    276    iris      ncol     6      a 1500.0263 secs
#> 28:    278    iris      ncol     6      c  500.0257 secs
#> 29:    279    iris      ncol     6      d  500.0311 secs
#> 30:    296    iris      ncol    10      a 1500.0283 secs
#> 31:    320    iris      ncol    14      e  500.0285 secs
#> 32:    340    iris      ncol    18      e  500.0265 secs
#> 33:    347    iris      ncol    20      b 1500.0267 secs
#> 34:    363    iris      ncol    23      c  500.0315 secs
#> 35:    369    iris      ncol    24      d  500.0278 secs
#> 36:    373    iris      ncol    25      c  500.0279 secs
#> 37:    387    iris      ncol    28      b 1500.0261 secs
#> 38:    410    iris      ncol    32      e  500.0263 secs
#> 39:    421    iris      ncol    35      a 1500.0320 secs
#> 40:    436    iris      ncol    38      a 1500.0284 secs
#> 41:    444    iris      ncol    39      d  500.0268 secs
#> 42:    448    iris      ncol    40      c  500.0262 secs
#> 43:    456    iris      ncol    42      a 1500.0312 secs
#> 44:    459    iris      ncol    42      d  500.0279 secs
#> 45:    467    iris      ncol    44      b 1500.0299 secs
#> 46:    468    iris      ncol    44      c  500.0263 secs
#> 47:    475    iris      ncol    45      e  500.0305 secs
#> 48:    482    iris      ncol    47      b 1500.0276 secs
#> 49:    492    iris      ncol    49      b 1500.0272 secs
#> 50:    499    iris      ncol    50      d  500.0265 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.4s
#>   Remaining: 3d 17h 38m 13.8s
#>   Total    : 4d 03h 21m 35.2s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1106.0427
#>   2:      2    iris      nrow     1      b estimated 1089.9973
#>   3:      3    iris      nrow     1      c estimated  337.9541
#>   4:      4    iris      nrow     1      d estimated  319.5934
#>   5:      5    iris      nrow     1      e estimated  319.0775
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1382.9428
#> 497:    497    iris      ncol    50      b estimated 1389.7917
#> 498:    498    iris      ncol    50      c estimated  616.6848
#> 499:    499    iris      ncol    50      d  observed  500.0265
#> 500:    500    iris      ncol    50      e estimated  577.6774
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.4s
#>   Remaining: 3d 17h 38m 13.8s
#>   Parallel : 0d 08h 58m 30.0s
#>   Total    : 4d 03h 21m 35.2s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1420.3205
#>   2:    461 estimated 1418.9272
#>   3:    462 estimated 1415.1853
#>   4:    457 estimated 1414.3853
#>   5:    472 estimated 1413.3386
#>  ---                           
#> 446:    194 estimated  133.3034
#> 447:    185 estimated  132.7944
#> 448:    174 estimated  131.1151
#> 449:    204 estimated  130.9532
#> 450:    179 estimated  129.9679
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0427    47
#>   2:      2 estimated 1089.9973    51
#>   3:      3 estimated  337.9541    55
#>   4:      4 estimated  319.5934    34
#>   5:      5 estimated  319.0775    71
#>  ---                                 
#> 446:    495 estimated  584.6120    15
#> 447:    496 estimated 1382.9428    20
#> 448:    497 estimated 1389.7917    14
#> 449:    498 estimated  616.6848     4
#> 450:    500 estimated  577.6774    22
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0427    47
#>   2:      2 estimated 1089.9973    51
#>   3:      3 estimated  337.9541    55
#>   4:      4 estimated  319.5934    34
#>   5:      5 estimated  319.0775    71
#>  ---                                 
#> 446:    495 estimated  584.6120    15
#> 447:    496 estimated 1382.9428    20
#> 448:    497 estimated 1389.7917    14
#> 449:    498 estimated  616.6848     4
#> 450:    500 estimated  577.6774    22
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3492.764
#>  2:    51 3596.110
#>  3:    55 3584.509
#>  4:    34 3594.210
#>  5:    71 3488.647
#>  6:    48 3487.524
#>  7:    52 3598.645
#>  8:    56 3574.639
#>  9:    72 3485.915
#> 10:    57 3565.698
#> 11:    69 3494.297
#> 12:    73 3478.812
#> 13:    58 3553.686
#> 14:    70 3491.955
#> 15:    74 3599.088
#> 16:    46 3517.204
#> 17:    50 3599.888
#> 18:    38 3596.850
#> 19:    36 3594.003
#> 20:    53 3594.944
#> 21:    39 3595.272
#> 22:    65 3513.441
#> 23:    43 3578.838
#> 24:    61 3532.963
#> 25:    63 3527.452
#> 26:    41 3587.865
#> 27:    54 3590.914
#> 28:    37 3599.973
#> 29:    49 3480.058
#> 30:    42 3584.034
#> 31:    60 3535.930
#> 32:    64 3525.250
#> 33:    40 3599.751
#> 34:    59 3544.746
#> 35:    62 3530.251
#> 36:    44 3545.990
#> 37:    35 3596.354
#> 38:    67 3507.769
#> 39:    45 3545.190
#> 40:    66 3508.337
#> 41:    68 3503.794
#> 42:    28 3595.085
#> 43:    24 3599.661
#> 44:    25 3590.988
#> 45:    27 3596.033
#> 46:    23 3599.667
#> 47:    26 3587.659
#> 48:    75 3599.570
#> 49:    12 3563.671
#> 50:     9 3587.091
#> 51:    21 3516.212
#> 52:    20 3520.428
#> 53:     8 3591.362
#> 54:    11 3565.839
#> 55:    10 3571.054
#> 56:     6 3596.859
#> 57:    33 3599.204
#> 58:     5 3599.833
#> 59:    32 3599.921
#> 60:     4 3596.628
#> 61:    81 3482.861
#> 62:     2 3599.664
#> 63:    84 3595.458
#> 64:    76 3598.579
#> 65:    83 3599.537
#> 66:    79 3503.893
#> 67:    80 3494.097
#> 68:    77 3527.556
#> 69:    86 3579.211
#> 70:    88 3558.736
#> 71:    91 2160.692
#> 72:    82 3470.856
#> 73:    89 3549.339
#> 74:    90 3520.540
#> 75:    78 3512.206
#> 76:    87 3567.135
#> 77:    85 3587.816
#> 78:     3 3599.729
#> 79:     1 3599.686
#> 80:     7 3594.181
#> 81:    30 3562.573
#> 82:    18 3574.811
#> 83:    13 3599.812
#> 84:    22 3599.291
#> 85:    19 3568.241
#> 86:    16 3588.715
#> 87:    31 3549.797
#> 88:    17 3580.458
#> 89:    29 3571.029
#> 90:    14 3599.550
#> 91:    15 3597.417
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
#>   1:      1 estimated 1106.0427     5
#>   2:      2 estimated 1089.9973     3
#>   3:      3 estimated  337.9541     3
#>   4:      4 estimated  319.5934     2
#>   5:      5 estimated  319.0775     3
#>  ---                                 
#> 446:    495 estimated  584.6120     6
#> 447:    496 estimated 1382.9428     7
#> 448:    497 estimated 1389.7917     6
#> 449:    498 estimated  616.6848     3
#> 450:    500 estimated  577.6774     2
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     5 32310.02
#>  2:     3 32296.58
#>  3:     2 32239.74
#>  4:     4 32296.18
#>  5:     7 32233.15
#>  6:     9 32309.29
#>  7:     6 32309.71
#>  8:     1 32233.45
#>  9:    10 32233.61
#> 10:     8 32232.07
```

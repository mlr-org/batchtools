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
#> 499:    499    499 1790871541 1790871541 1790872041   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job530d24ce80f5337520a37b0505805217     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0237 secs
#>  2:     42    iris      nrow     9      b 1100.0282 secs
#>  3:     47    iris      nrow    10      b 1100.0231 secs
#>  4:     66    iris      nrow    14      a 1100.0232 secs
#>  5:     73    iris      nrow    15      c  100.0223 secs
#>  6:     75    iris      nrow    15      e  100.0221 secs
#>  7:     86    iris      nrow    18      a 1100.0222 secs
#>  8:    100    iris      nrow    20      e  100.0231 secs
#>  9:    101    iris      nrow    21      a 1100.0230 secs
#> 10:    103    iris      nrow    21      c  100.0223 secs
#> 11:    123    iris      nrow    25      c  100.0219 secs
#> 12:    125    iris      nrow    25      e  100.0218 secs
#> 13:    161    iris      nrow    33      a 1100.0266 secs
#> 14:    165    iris      nrow    33      e  100.0234 secs
#> 15:    169    iris      nrow    34      d  100.0227 secs
#> 16:    183    iris      nrow    37      c  100.0221 secs
#> 17:    184    iris      nrow    37      d  100.0219 secs
#> 18:    203    iris      nrow    41      c  100.0218 secs
#> 19:    207    iris      nrow    42      b 1100.0232 secs
#> 20:    209    iris      nrow    42      d  100.0227 secs
#> 21:    220    iris      nrow    44      e  100.0224 secs
#> 22:    227    iris      nrow    46      b 1100.0221 secs
#> 23:    229    iris      nrow    46      d  100.0218 secs
#> 24:    231    iris      nrow    47      a 1100.0272 secs
#> 25:    244    iris      nrow    49      d  100.0229 secs
#> 26:    260    iris      ncol     2      e  500.0228 secs
#> 27:    276    iris      ncol     6      a 1500.0219 secs
#> 28:    278    iris      ncol     6      c  500.0217 secs
#> 29:    279    iris      ncol     6      d  500.0277 secs
#> 30:    296    iris      ncol    10      a 1500.0231 secs
#> 31:    320    iris      ncol    14      e  500.0229 secs
#> 32:    340    iris      ncol    18      e  500.0220 secs
#> 33:    347    iris      ncol    20      b 1500.0218 secs
#> 34:    363    iris      ncol    23      c  500.0284 secs
#> 35:    369    iris      ncol    24      d  500.0226 secs
#> 36:    373    iris      ncol    25      c  500.0227 secs
#> 37:    387    iris      ncol    28      b 1500.0221 secs
#> 38:    410    iris      ncol    32      e  500.0218 secs
#> 39:    421    iris      ncol    35      a 1500.0274 secs
#> 40:    436    iris      ncol    38      a 1500.0227 secs
#> 41:    444    iris      ncol    39      d  500.0220 secs
#> 42:    448    iris      ncol    40      c  500.0220 secs
#> 43:    456    iris      ncol    42      a 1500.0279 secs
#> 44:    459    iris      ncol    42      d  500.0226 secs
#> 45:    467    iris      ncol    44      b 1500.0221 secs
#> 46:    468    iris      ncol    44      c  500.0219 secs
#> 47:    475    iris      ncol    45      e  500.0268 secs
#> 48:    482    iris      ncol    47      b 1500.0225 secs
#> 49:    492    iris      ncol    49      b 1500.0222 secs
#> 50:    499    iris      ncol    50      d  500.0219 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.2s
#>   Remaining: 3d 17h 37m 26.5s
#>   Total    : 4d 03h 20m 47.7s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1106.0380
#>   2:      2    iris      nrow     1      b estimated 1089.9925
#>   3:      3    iris      nrow     1      c estimated  337.7896
#>   4:      4    iris      nrow     1      d estimated  319.8554
#>   5:      5    iris      nrow     1      e estimated  318.8327
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1382.0630
#> 497:    497    iris      ncol    50      b estimated 1389.1114
#> 498:    498    iris      ncol    50      c estimated  615.6454
#> 499:    499    iris      ncol    50      d  observed  500.0219
#> 500:    500    iris      ncol    50      e estimated  577.1979
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.2s
#>   Remaining: 3d 17h 37m 26.5s
#>   Parallel : 0d 08h 58m 25.8s
#>   Total    : 4d 03h 20m 47.7s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1423.4405
#>   2:    461 estimated 1420.0474
#>   3:    472 estimated 1416.2581
#>   4:    462 estimated 1416.1050
#>   5:    457 estimated 1415.3050
#>  ---                           
#> 446:    164 estimated  133.4600
#> 447:    185 estimated  133.1895
#> 448:    204 estimated  131.3484
#> 449:    174 estimated  131.1099
#> 450:    179 estimated  129.9631
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0380    47
#>   2:      2 estimated 1089.9925    52
#>   3:      3 estimated  337.7896    37
#>   4:      4 estimated  319.8554    34
#>   5:      5 estimated  318.8327    33
#>  ---                                 
#> 446:    495 estimated  583.3325    15
#> 447:    496 estimated 1382.0630    21
#> 448:    497 estimated 1389.1114    15
#> 449:    498 estimated  615.6454     4
#> 450:    500 estimated  577.1979    22
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0380    47
#>   2:      2 estimated 1089.9925    52
#>   3:      3 estimated  337.7896    37
#>   4:      4 estimated  319.8554    34
#>   5:      5 estimated  318.8327    33
#>  ---                                 
#> 446:    495 estimated  583.3325    15
#> 447:    496 estimated 1382.0630    21
#> 448:    497 estimated 1389.1114    15
#> 449:    498 estimated  615.6454     4
#> 450:    500 estimated  577.1979    22
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3492.504
#>  2:    52 3598.893
#>  3:    37 3599.792
#>  4:    34 3595.098
#>  5:    33 3599.039
#>  6:    48 3488.725
#>  7:    55 3584.331
#>  8:    51 3596.839
#>  9:    71 3487.944
#> 10:    56 3574.060
#> 11:    69 3493.944
#> 12:    72 3485.642
#> 13:    53 3595.826
#> 14:    57 3565.319
#> 15:    70 3491.862
#> 16:    73 3478.553
#> 17:    46 3518.012
#> 18:    50 3599.825
#> 19:    38 3597.112
#> 20:    65 3512.964
#> 21:    39 3594.805
#> 22:    66 3508.339
#> 23:    43 3578.643
#> 24:    61 3532.925
#> 25:    63 3526.593
#> 26:    40 3597.306
#> 27:    54 3591.161
#> 28:    58 3553.274
#> 29:    49 3485.941
#> 30:    42 3583.839
#> 31:    60 3535.977
#> 32:    36 3599.851
#> 33:    41 3585.029
#> 34:    59 3544.995
#> 35:    62 3529.477
#> 36:    44 3546.078
#> 37:    35 3596.584
#> 38:    67 3506.930
#> 39:    45 3545.055
#> 40:    64 3517.573
#> 41:    68 3503.135
#> 42:    27 3599.128
#> 43:    24 3598.025
#> 44:    26 3587.130
#> 45:    25 3599.536
#> 46:    29 3568.594
#> 47:    28 3575.918
#> 48:    74 3472.355
#> 49:    75 3599.803
#> 50:    11 3567.546
#> 51:     9 3590.610
#> 52:    20 3521.079
#> 53:    21 3515.589
#> 54:     8 3594.219
#> 55:     5 3594.131
#> 56:    12 3564.708
#> 57:    10 3579.964
#> 58:     6 3599.571
#> 59:    32 3599.765
#> 60:     4 3599.632
#> 61:    80 3483.683
#> 62:    82 3599.745
#> 63:    83 3599.650
#> 64:    79 3497.552
#> 65:    81 3476.943
#> 66:    76 3589.989
#> 67:    85 3582.291
#> 68:    88 3556.052
#> 69:    91 2164.865
#> 70:     3 3599.011
#> 71:    89 3546.098
#> 72:    78 3504.437
#> 73:    77 3519.660
#> 74:    87 3566.363
#> 75:    84 3590.367
#> 76:    86 3572.643
#> 77:     1 3599.255
#> 78:     2 3599.971
#> 79:    90 3520.356
#> 80:     7 3597.096
#> 81:    30 3562.439
#> 82:    18 3577.949
#> 83:    14 3597.334
#> 84:    22 3598.618
#> 85:    19 3571.379
#> 86:    17 3586.009
#> 87:    31 3550.099
#> 88:    13 3597.638
#> 89:    23 3599.597
#> 90:    16 3595.247
#> 91:    15 3597.086
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
#>   1:      1 estimated 1106.0380     2
#>   2:      2 estimated 1089.9925     1
#>   3:      3 estimated  337.7896     4
#>   4:      4 estimated  319.8554    10
#>   5:      5 estimated  318.8327     8
#>  ---                                 
#> 446:    495 estimated  583.3325     2
#> 447:    496 estimated 1382.0630     6
#> 448:    497 estimated 1389.1114     1
#> 449:    498 estimated  615.6454     3
#> 450:    500 estimated  577.1979    10
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     2 32305.71
#>  2:     1 32229.10
#>  3:     4 32228.73
#>  4:    10 32235.00
#>  5:     8 32290.39
#>  6:     9 32228.19
#>  7:     6 32290.50
#>  8:     7 32305.76
#>  9:     5 32228.29
#> 10:     3 32304.85
```

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
#> 499:    499    499 1790003174 1790003174 1790003674   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job65775fb5452c3761c6f0e61bf235fde4     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0264 secs
#>  2:     42    iris      nrow     9      b 1100.0257 secs
#>  3:     47    iris      nrow    10      b 1100.0258 secs
#>  4:     66    iris      nrow    14      a 1100.0299 secs
#>  5:     73    iris      nrow    15      c  100.0257 secs
#>  6:     75    iris      nrow    15      e  100.0259 secs
#>  7:     86    iris      nrow    18      a 1100.0257 secs
#>  8:    100    iris      nrow    20      e  100.0255 secs
#>  9:    101    iris      nrow    21      a 1100.0264 secs
#> 10:    103    iris      nrow    21      c  100.0259 secs
#> 11:    123    iris      nrow    25      c  100.0257 secs
#> 12:    125    iris      nrow    25      e  100.0262 secs
#> 13:    161    iris      nrow    33      a 1100.0258 secs
#> 14:    165    iris      nrow    33      e  100.0264 secs
#> 15:    169    iris      nrow    34      d  100.0298 secs
#> 16:    183    iris      nrow    37      c  100.0271 secs
#> 17:    184    iris      nrow    37      d  100.0267 secs
#> 18:    203    iris      nrow    41      c  100.0266 secs
#> 19:    207    iris      nrow    42      b 1100.0264 secs
#> 20:    209    iris      nrow    42      d  100.0267 secs
#> 21:    220    iris      nrow    44      e  100.0261 secs
#> 22:    227    iris      nrow    46      b 1100.0258 secs
#> 23:    229    iris      nrow    46      d  100.0281 secs
#> 24:    231    iris      nrow    47      a 1100.0275 secs
#> 25:    244    iris      nrow    49      d  100.0270 secs
#> 26:    260    iris      ncol     2      e  500.0305 secs
#> 27:    276    iris      ncol     6      a 1500.0268 secs
#> 28:    278    iris      ncol     6      c  500.0268 secs
#> 29:    279    iris      ncol     6      d  500.0277 secs
#> 30:    296    iris      ncol    10      a 1500.0273 secs
#> 31:    320    iris      ncol    14      e  500.0302 secs
#> 32:    340    iris      ncol    18      e  500.0262 secs
#> 33:    347    iris      ncol    20      b 1500.0270 secs
#> 34:    363    iris      ncol    23      c  500.0272 secs
#> 35:    369    iris      ncol    24      d  500.0267 secs
#> 36:    373    iris      ncol    25      c  500.0305 secs
#> 37:    387    iris      ncol    28      b 1500.0256 secs
#> 38:    410    iris      ncol    32      e  500.0268 secs
#> 39:    421    iris      ncol    35      a 1500.0259 secs
#> 40:    436    iris      ncol    38      a 1500.0260 secs
#> 41:    444    iris      ncol    39      d  500.0298 secs
#> 42:    448    iris      ncol    40      c  500.0262 secs
#> 43:    456    iris      ncol    42      a 1500.0259 secs
#> 44:    459    iris      ncol    42      d  500.0262 secs
#> 45:    467    iris      ncol    44      b 1500.0303 secs
#> 46:    468    iris      ncol    44      c  500.0261 secs
#> 47:    475    iris      ncol    45      e  500.0258 secs
#> 48:    482    iris      ncol    47      b 1500.0258 secs
#> 49:    492    iris      ncol    49      b 1500.0300 secs
#> 50:    499    iris      ncol    50      d  500.0259 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.3s
#>   Remaining: 3d 17h 37m 21.2s
#>   Total    : 4d 03h 20m 42.6s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1105.4808
#>   2:      2    iris      nrow     1      b estimated 1089.2746
#>   3:      3    iris      nrow     1      c estimated  338.2333
#>   4:      4    iris      nrow     1      d estimated  318.6593
#>   5:      5    iris      nrow     1      e estimated  318.1432
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1383.7463
#> 497:    497    iris      ncol    50      b estimated 1390.9966
#> 498:    498    iris      ncol    50      c estimated  616.8091
#> 499:    499    iris      ncol    50      d  observed  500.0259
#> 500:    500    iris      ncol    50      e estimated  577.0013
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.3s
#>   Remaining: 3d 17h 37m 21.2s
#>   Parallel : 0d 08h 58m 25.4s
#>   Total    : 4d 03h 20m 42.6s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1422.2432
#>   2:    461 estimated 1420.8494
#>   3:    462 estimated 1417.0233
#>   4:    457 estimated 1417.0233
#>   5:    472 estimated 1416.1771
#>  ---                           
#> 446:    164 estimated  133.2247
#> 447:    185 estimated  132.9537
#> 448:    174 estimated  130.8752
#> 449:    204 estimated  130.7130
#> 450:    179 estimated  129.7280
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.4808    47
#>   2:      2 estimated 1089.2746    52
#>   3:      3 estimated  338.2333    54
#>   4:      4 estimated  318.6593    34
#>   5:      5 estimated  318.1432    71
#>  ---                                 
#> 446:    495 estimated  583.9359    15
#> 447:    496 estimated 1383.7463    20
#> 448:    497 estimated 1390.9966    13
#> 449:    498 estimated  616.8091     4
#> 450:    500 estimated  577.0013    22
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1105.4808    47
#>   2:      2 estimated 1089.2746    52
#>   3:      3 estimated  338.2333    54
#>   4:      4 estimated  318.6593    34
#>   5:      5 estimated  318.1432    71
#>  ---                                 
#> 446:    495 estimated  583.9359    15
#> 447:    496 estimated 1383.7463    20
#> 448:    497 estimated 1390.9966    13
#> 449:    498 estimated  616.8091     4
#> 450:    500 estimated  577.0013    22
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3491.903
#>  2:    52 3595.543
#>  3:    54 3590.320
#>  4:    34 3595.314
#>  5:    71 3488.476
#>  6:    48 3485.837
#>  7:    55 3584.524
#>  8:    51 3597.491
#>  9:    72 3485.195
#> 10:    56 3573.940
#> 11:    69 3493.262
#> 12:    73 3478.552
#> 13:    53 3599.879
#> 14:    57 3565.245
#> 15:    70 3490.622
#> 16:    74 3599.296
#> 17:    46 3516.183
#> 18:    50 3599.836
#> 19:    38 3596.666
#> 20:    36 3595.048
#> 21:    64 3515.988
#> 22:    43 3566.755
#> 23:    65 3511.863
#> 24:    42 3576.555
#> 25:    37 3599.817
#> 26:    39 3597.016
#> 27:    58 3552.101
#> 28:    59 3543.128
#> 29:    49 3477.626
#> 30:    41 3588.876
#> 31:    61 3531.758
#> 32:    63 3524.797
#> 33:    40 3596.043
#> 34:    60 3534.899
#> 35:    62 3528.538
#> 36:    44 3537.894
#> 37:    35 3596.503
#> 38:    67 3506.078
#> 39:    45 3537.094
#> 40:    66 3506.316
#> 41:    68 3502.703
#> 42:    28 3599.061
#> 43:    25 3595.749
#> 44:    26 3593.440
#> 45:    29 3588.573
#> 46:    24 3598.670
#> 47:    27 3588.253
#> 48:    75 3599.873
#> 49:    12 3561.358
#> 50:     7 3599.970
#> 51:    21 3520.111
#> 52:    20 3523.646
#> 53:     9 3593.408
#> 54:     6 3594.255
#> 55:     5 3599.177
#> 56:    11 3574.162
#> 57:    33 3599.561
#> 58:    10 3579.139
#> 59:    32 3599.189
#> 60:    82 3599.818
#> 61:    84 3594.883
#> 62:     4 3599.858
#> 63:    80 3487.425
#> 64:    81 3475.998
#> 65:    77 3526.663
#> 66:    86 3572.797
#> 67:    87 3563.861
#> 68:    91 2158.710
#> 69:    79 3497.009
#> 70:    89 3546.170
#> 71:    88 3555.753
#> 72:    78 3506.831
#> 73:    76 3595.209
#> 74:    83 3599.629
#> 75:    90 3522.969
#> 76:    85 3582.335
#> 77:     3 3599.801
#> 78:     2 3599.697
#> 79:     8 3598.066
#> 80:    23 3596.570
#> 81:    18 3574.922
#> 82:    13 3598.057
#> 83:    22 3597.812
#> 84:    19 3571.552
#> 85:    16 3587.843
#> 86:    31 3551.944
#> 87:    17 3581.097
#> 88:    30 3570.617
#> 89:    15 3594.264
#> 90:    14 3599.133
#> 91:     1 3470.861
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
#>   1:      1 estimated 1105.4808     8
#>   2:      2 estimated 1089.2746     5
#>   3:      3 estimated  338.2333     5
#>   4:      4 estimated  318.6593     9
#>   5:      5 estimated  318.1432     3
#>  ---                                 
#> 446:    495 estimated  583.9359     5
#> 447:    496 estimated 1383.7463     3
#> 448:    497 estimated 1390.9966     2
#> 449:    498 estimated  616.8091     9
#> 450:    500 estimated  577.0013     7
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     8 32228.03
#>  2:     5 32228.04
#>  3:     9 32232.97
#>  4:     3 32290.47
#>  5:     7 32305.03
#>  6:    10 32228.35
#>  7:     2 32227.88
#>  8:     4 32304.47
#>  9:     1 32305.41
#> 10:     6 32290.56
```

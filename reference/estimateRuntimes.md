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
#> 499:    499    499 1791383574 1791383574 1791384074   <NA>       NA           1
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
#> 499: cfInteractive     <NA> job58486505b67df9911d7f8f7ebcd2a414     <NA>     1
#> 500:          <NA>     <NA>                                <NA>     <NA>     1
rjoin(sjoin(tab, ids), getJobStatus(ids, reg = tmp)[, c("job.id", "time.running")])
#> Key: <job.id>
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>
#>  1:     32    iris      nrow     7      b 1100.0237 secs
#>  2:     42    iris      nrow     9      b 1100.0276 secs
#>  3:     47    iris      nrow    10      b 1100.0235 secs
#>  4:     66    iris      nrow    14      a 1100.0235 secs
#>  5:     73    iris      nrow    15      c  100.0213 secs
#>  6:     75    iris      nrow    15      e  100.0215 secs
#>  7:     86    iris      nrow    18      a 1100.0217 secs
#>  8:    100    iris      nrow    20      e  100.0231 secs
#>  9:    101    iris      nrow    21      a 1100.0228 secs
#> 10:    103    iris      nrow    21      c  100.0227 secs
#> 11:    123    iris      nrow    25      c  100.0229 secs
#> 12:    125    iris      nrow    25      e  100.0215 secs
#> 13:    161    iris      nrow    33      a 1100.0258 secs
#> 14:    165    iris      nrow    33      e  100.0244 secs
#> 15:    169    iris      nrow    34      d  100.0233 secs
#> 16:    183    iris      nrow    37      c  100.0215 secs
#> 17:    184    iris      nrow    37      d  100.0218 secs
#> 18:    203    iris      nrow    41      c  100.0214 secs
#> 19:    207    iris      nrow    42      b 1100.0240 secs
#> 20:    209    iris      nrow    42      d  100.0238 secs
#> 21:    220    iris      nrow    44      e  100.0229 secs
#> 22:    227    iris      nrow    46      b 1100.0216 secs
#> 23:    229    iris      nrow    46      d  100.0216 secs
#> 24:    231    iris      nrow    47      a 1100.0266 secs
#> 25:    244    iris      nrow    49      d  100.0234 secs
#> 26:    260    iris      ncol     2      e  500.0237 secs
#> 27:    276    iris      ncol     6      a 1500.0224 secs
#> 28:    278    iris      ncol     6      c  500.0211 secs
#> 29:    279    iris      ncol     6      d  500.0265 secs
#> 30:    296    iris      ncol    10      a 1500.0240 secs
#> 31:    320    iris      ncol    14      e  500.0239 secs
#> 32:    340    iris      ncol    18      e  500.0218 secs
#> 33:    347    iris      ncol    20      b 1500.0223 secs
#> 34:    363    iris      ncol    23      c  500.0271 secs
#> 35:    369    iris      ncol    24      d  500.0235 secs
#> 36:    373    iris      ncol    25      c  500.0239 secs
#> 37:    387    iris      ncol    28      b 1500.0223 secs
#> 38:    410    iris      ncol    32      e  500.0217 secs
#> 39:    421    iris      ncol    35      a 1500.0266 secs
#> 40:    436    iris      ncol    38      a 1500.0237 secs
#> 41:    444    iris      ncol    39      d  500.0216 secs
#> 42:    448    iris      ncol    40      c  500.0213 secs
#> 43:    456    iris      ncol    42      a 1500.0264 secs
#> 44:    459    iris      ncol    42      d  500.0239 secs
#> 45:    467    iris      ncol    44      b 1500.0230 secs
#> 46:    468    iris      ncol    44      c  500.0217 secs
#> 47:    475    iris      ncol    45      e  500.0264 secs
#> 48:    482    iris      ncol    47      b 1500.0231 secs
#> 49:    492    iris      ncol    49      b 1500.0227 secs
#> 50:    499    iris      ncol    50      d  500.0222 secs
#>     job.id problem algorithm     x      y   time.running
#>      <int>  <char>    <char> <int> <char>     <difftime>

# Estimate runtimes:
est = estimateRuntimes(tab, reg = tmp)
print(est)
#> Runtime Estimate for 500 jobs with 1 CPUs
#>   Done     : 0d 09h 43m 21.2s
#>   Remaining: 3d 17h 37m 46.6s
#>   Total    : 4d 03h 21m 7.8s
rjoin(tab, est$runtimes)
#> Key: <job.id>
#>      job.id problem algorithm     x      y      type   runtime
#>       <int>  <char>    <char> <int> <char>    <fctr>     <num>
#>   1:      1    iris      nrow     1      a estimated 1106.0379
#>   2:      2    iris      nrow     1      b estimated 1089.9924
#>   3:      3    iris      nrow     1      c estimated  337.7893
#>   4:      4    iris      nrow     1      d estimated  319.5886
#>   5:      5    iris      nrow     1      e estimated  318.8325
#>  ---                                                          
#> 496:    496    iris      ncol    50      a estimated 1382.9380
#> 497:    497    iris      ncol    50      b estimated 1389.9868
#> 498:    498    iris      ncol    50      c estimated  616.7203
#> 499:    499    iris      ncol    50      d  observed  500.0222
#> 500:    500    iris      ncol    50      e estimated  578.2729
print(est, n = 10)
#> Runtime Estimate for 500 jobs with 10 CPUs
#>   Done     : 0d 09h 43m 21.2s
#>   Remaining: 3d 17h 37m 46.6s
#>   Parallel : 0d 08h 58m 28.0s
#>   Total    : 4d 03h 21m 7.8s

# Submit jobs with longest runtime first:
ids = est$runtimes[type == "estimated"][order(runtime, decreasing = TRUE)]
print(ids)
#>      job.id      type   runtime
#>       <int>    <fctr>     <num>
#>   1:    466 estimated 1420.3155
#>   2:    461 estimated 1418.9223
#>   3:    462 estimated 1414.9803
#>   4:    457 estimated 1414.1803
#>   5:    487 estimated 1413.5056
#>  ---                           
#> 446:    199 estimated  132.0589
#> 447:    194 estimated  131.8988
#> 448:    204 estimated  131.1486
#> 449:    174 estimated  131.1103
#> 450:    179 estimated  129.9633
if (FALSE) { # \dontrun{
submitJobs(ids, reg = tmp)
} # }

# Group jobs into chunks with runtime < 1h
ids = est$runtimes[type == "estimated"]
ids[, chunk := binpack(runtime, 3600)]
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0379    47
#>   2:      2 estimated 1089.9924    52
#>   3:      3 estimated  337.7893    37
#>   4:      4 estimated  319.5886    34
#>   5:      5 estimated  318.8325    71
#>  ---                                 
#> 446:    495 estimated  585.2076    15
#> 447:    496 estimated 1382.9380    20
#> 448:    497 estimated 1389.9868    14
#> 449:    498 estimated  616.7203     4
#> 450:    500 estimated  578.2729    20
print(ids)
#> Key: <job.id>
#>      job.id      type   runtime chunk
#>       <int>    <fctr>     <num> <int>
#>   1:      1 estimated 1106.0379    47
#>   2:      2 estimated 1089.9924    52
#>   3:      3 estimated  337.7893    37
#>   4:      4 estimated  319.5886    34
#>   5:      5 estimated  318.8325    71
#>  ---                                 
#> 446:    495 estimated  585.2076    15
#> 447:    496 estimated 1382.9380    20
#> 448:    497 estimated 1389.9868    14
#> 449:    498 estimated  616.7203     4
#> 450:    500 estimated  578.2729    20
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:    47 3492.504
#>  2:    52 3598.626
#>  3:    37 3599.748
#>  4:    34 3594.832
#>  5:    71 3487.944
#>  6:    48 3488.262
#>  7:    55 3583.377
#>  8:    51 3596.572
#>  9:    72 3485.641
#> 10:    56 3572.631
#> 11:    69 3493.678
#> 12:    73 3478.552
#> 13:    53 3595.558
#> 14:    57 3564.366
#> 15:    70 3491.594
#> 16:    74 3599.971
#> 17:    46 3516.945
#> 18:    50 3599.640
#> 19:    38 3597.112
#> 20:    64 3517.327
#> 21:    39 3594.934
#> 22:    65 3512.963
#> 23:    43 3578.420
#> 24:    61 3532.658
#> 25:    63 3526.593
#> 26:    41 3587.446
#> 27:    54 3590.894
#> 28:    58 3553.630
#> 29:    49 3479.403
#> 30:    40 3599.653
#> 31:    60 3535.710
#> 32:    36 3599.852
#> 33:    42 3584.176
#> 34:    59 3544.727
#> 35:    62 3529.477
#> 36:    44 3545.812
#> 37:    35 3596.095
#> 38:    67 3506.929
#> 39:    45 3545.012
#> 40:    66 3508.317
#> 41:    68 3503.135
#> 42:    28 3594.906
#> 43:    24 3599.242
#> 44:    25 3590.090
#> 45:    27 3595.615
#> 46:    23 3599.448
#> 47:    26 3586.960
#> 48:    75 3599.987
#> 49:    12 3563.292
#> 50:     9 3587.110
#> 51:    20 3520.060
#> 52:    21 3516.513
#> 53:     8 3591.423
#> 54:    10 3571.077
#> 55:    11 3565.460
#> 56:     6 3597.320
#> 57:    33 3599.715
#> 58:     5 3599.926
#> 59:    32 3599.917
#> 60:     4 3596.457
#> 61:    81 3481.599
#> 62:    76 3596.906
#> 63:     2 3599.925
#> 64:    82 3470.092
#> 65:     3 3599.977
#> 66:    80 3490.561
#> 67:    77 3525.890
#> 68:    84 3593.571
#> 69:    86 3576.115
#> 70:    91 2157.126
#> 71:    90 3518.163
#> 72:    78 3510.495
#> 73:    89 3549.866
#> 74:    88 3560.235
#> 75:    79 3502.039
#> 76:    85 3586.315
#> 77:    83 3599.983
#> 78:    87 3568.740
#> 79:     1 3599.907
#> 80:     7 3594.999
#> 81:    30 3562.752
#> 82:    18 3575.790
#> 83:    14 3596.601
#> 84:    22 3599.023
#> 85:    19 3568.863
#> 86:    13 3599.184
#> 87:    31 3550.299
#> 88:    17 3581.479
#> 89:    29 3570.811
#> 90:    16 3595.672
#> 91:    15 3598.398
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
#>   1:      1 estimated 1106.0379     4
#>   2:      2 estimated 1089.9924     9
#>   3:      3 estimated  337.7893     1
#>   4:      4 estimated  319.5886     8
#>   5:      5 estimated  318.8325     9
#>  ---                                 
#> 446:    495 estimated  585.2076     9
#> 447:    496 estimated 1382.9380     7
#> 448:    497 estimated 1389.9868     3
#> 449:    498 estimated  616.7203     4
#> 450:    500 estimated  578.2729     8
print(ids[, list(runtime = sum(runtime)), by = chunk])
#>     chunk  runtime
#>     <int>    <num>
#>  1:     4 32307.69
#>  2:     9 32292.29
#>  3:     1 32230.86
#>  4:     8 32236.60
#>  5:     7 32229.81
#>  6:     6 32231.31
#>  7:     5 32308.04
#>  8:    10 32229.83
#>  9:     3 32292.30
#> 10:     2 32307.89
```

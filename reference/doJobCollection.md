# Execute Jobs of a JobCollection

Executes every job in a
[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md).
This function is intended to be called on the slave.

## Usage

``` r
doJobCollection(jc, output = NULL)
```

## Arguments

- jc:

  \[[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)\]  
  Either an object of class “JobCollection” as returned by
  [`makeJobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
  or a string with the path to file containing a “JobCollection” as RDS
  file (as stored by
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md)).

- output:

  \[`character(1)`\]  
  Path to a file to write the output to. Defaults to `NULL` which means
  that output is written to the active
  [`sink`](https://rdrr.io/r/base/sink.html). Do not set this if your
  scheduler redirects output to a log file.

## Value

\[`character(1)`\]: Hash of the
[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
executed.

## See also

Other JobCollection:
[`makeJobCollection()`](https://batchtools.mlr-org.com/reference/JobCollection.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(identity, 1:2, reg = tmp)
#> Adding 2 jobs ...
jc = makeJobCollection(1:2, reg = tmp)
doJobCollection(jc)
#> ### [bt]: This is batchtools v0.9.18
#> ### [bt]: Starting calculation of 2 jobs
#> ### [bt]: Setting working directory to '/home/runner/work/batchtools/batchtools/docs/reference'
#> ### [bt]: Memory measurement disabled
#> ### [bt]: Starting job [batchtools job.id=1]
#> ### [bt]: Setting seed to 30429 ...
#> 
#> ### [bt]: Job terminated successfully [batchtools job.id=1]
#> ### [bt]: Starting job [batchtools job.id=2]
#> ### [bt]: Setting seed to 30430 ...
#> 
#> ### [bt]: Job terminated successfully [batchtools job.id=2]
#> ### [bt]: Calculation finished!
```

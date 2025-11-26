# Execute a Single Jobs

Executes a single job (as created by
[`makeJob`](https://batchtools.mlr-org.com/reference/JobExperiment.md))
and returns its result. Also works for Experiments.

## Usage

``` r
execJob(job)
```

## Arguments

- job:

  \[[`Job`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  \|
  [`Experiment`](https://batchtools.mlr-org.com/reference/JobExperiment.md)\]  
  Job/Experiment to execute.

## Value

Result of the job.

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(identity, 1:2, reg = tmp)
#> Adding 2 jobs ...
job = makeJob(1, reg = tmp)
execJob(job)
#> ### [bt]: Setting seed to 29343 ...
#> [1] 1
```

# Query Job Information

`getJobStatus` returns the internal table which stores information about
the computational status of jobs, `getJobPars` a table with the job
parameters, `getJobResources` a table with the resources which were set
to submit the jobs, and `getJobTags` the tags of the jobs (see
[Tags](https://batchtools.mlr-org.com/reference/Tags.md)).

`getJobTable` returns all these tables joined.

## Usage

``` r
getJobTable(ids = NULL, reg = getDefaultRegistry())

getJobStatus(ids = NULL, reg = getDefaultRegistry())

getJobResources(ids = NULL, reg = getDefaultRegistry())

getJobPars(ids = NULL, reg = getDefaultRegistry())

getJobTags(ids = NULL, reg = getDefaultRegistry())
```

## Arguments

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdrr.io/pkg/data.table/man/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to all jobs.
  Invalid ids are ignored.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdrr.io/pkg/data.table/man/data.table.html)\]
with the following columns (not necessarily in this order):

- job.id:

  Unique Job ID as integer.

- submitted:

  Time the job was submitted to the batch system as
  [`POSIXct`](https://rdrr.io/r/base/DateTimeClasses.html).

- started:

  Time the job was started on the batch system as
  [`POSIXct`](https://rdrr.io/r/base/DateTimeClasses.html).

- done:

  Time the job terminated (successfully or with an error) as
  [`POSIXct`](https://rdrr.io/r/base/DateTimeClasses.html).

- error:

  Either `NA` if the job terminated successfully or the error message.

- mem.used:

  Estimate of the memory usage.

- batch.id:

  Batch ID as reported by the scheduler.

- log.file:

  Log file. If missing, defaults to `[job.hash].log`.

- job.hash:

  Unique string identifying the job or chunk.

- time.queued:

  Time in seconds (as
  [`difftime`](https://rdrr.io/r/base/difftime.html)) the job was
  queued.

- time.running:

  Time in seconds (as
  [`difftime`](https://rdrr.io/r/base/difftime.html)) the job was
  running.

- pars:

  List of parameters/arguments for this job.

- resources:

  List of computational resources set for this job.

- tags:

  Tags as joined string, delimited by “,”.

- problem:

  Only for
  [`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md):
  the problem identifier.

- algorithm:

  Only for
  [`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md):
  the algorithm identifier.

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
f = function(x) if (x < 0) stop("x must be > 0") else sqrt(x)
batchMap(f, x = c(-1, 0, 1), reg = tmp)
#> Adding 3 jobs ...
submitJobs(reg = tmp)
#> Submitting 3 jobs in 3 chunks using cluster functions 'Interactive' ...
#> Error in (function (x)  : x must be > 0
waitForJobs(reg = tmp)
#> [1] FALSE
addJobTags(1:2, "tag1", reg = tmp)
addJobTags(2, "tag2", reg = tmp)

# Complete table:
getJobTable(reg = tmp)
#> Key: <job.id>
#>    job.id           submitted             started                done
#>     <int>              <POSc>              <POSc>              <POSc>
#> 1:      1 2026-09-21 15:09:58 2026-09-21 15:09:58 2026-09-21 15:09:58
#> 2:      2 2026-09-21 15:09:58 2026-09-21 15:09:58 2026-09-21 15:09:58
#> 3:      3 2026-09-21 15:09:58 2026-09-21 15:09:58 2026-09-21 15:09:58
#>                                      error mem.used      batch.id log.file
#>                                     <char>    <num>        <char>   <char>
#> 1: Error in (function (x)  : x must be > 0       NA cfInteractive     <NA>
#> 2:                                    <NA>       NA cfInteractive     <NA>
#> 3:                                    <NA>       NA cfInteractive     <NA>
#>                               job.hash job.name      time.queued   time.running
#>                                 <char>   <char>       <difftime>     <difftime>
#> 1: jobac8803e5b4a0413366c67b27af060ec7     <NA> 0.004099846 secs 0.2247000 secs
#> 2: jobb7037765bb316ea6e70ec97fd032ca91     <NA> 0.004300117 secs 0.2158000 secs
#> 3: joba78f97eda83a6a1fd597c84b02b2d48f     <NA> 0.004299879 secs 0.2320001 secs
#>     job.pars resources      tags
#>       <list>    <list>    <char>
#> 1: <list[1]> <list[0]>      tag1
#> 2: <list[1]> <list[0]> tag1,tag2
#> 3: <list[1]> <list[0]>      <NA>

# Job parameters:
getJobPars(reg = tmp)
#> Key: <job.id>
#>    job.id  job.pars
#>     <int>    <list>
#> 1:      1 <list[1]>
#> 2:      2 <list[1]>
#> 3:      3 <list[1]>

# Set and retrieve tags:
getJobTags(reg = tmp)
#> Key: <job.id>
#>    job.id      tags
#>     <int>    <char>
#> 1:      1      tag1
#> 2:      2 tag1,tag2
#> 3:      3      <NA>

# Job parameters with tags right-joined:
rjoin(getJobPars(reg = tmp), getJobTags(reg = tmp))
#> Key: <job.id>
#>    job.id  job.pars      tags
#>     <int>    <list>    <char>
#> 1:      1 <list[1]>      tag1
#> 2:      2 <list[1]> tag1,tag2
#> 3:      3 <list[1]>      <NA>
```

# ClusterFunctions Constructor

This is the constructor used to create *custom* cluster functions. Note
that some standard implementations for TORQUE, Slurm, LSF, SGE, etc.
ship with the package.

## Usage

``` r
makeClusterFunctions(
  name,
  submitJob,
  killJob = NULL,
  listJobsQueued = NULL,
  listJobsRunning = NULL,
  array.var = NA_character_,
  store.job.collection = FALSE,
  store.job.files = FALSE,
  scheduler.latency = 0,
  fs.latency = 0,
  hooks = list()
)
```

## Arguments

- name:

  \[`character(1)`\]  
  Name of cluster functions.

- submitJob:

  \[`function(reg, jc, ...)`\]  
  Function to submit new jobs. Must return a
  [`SubmitJobResult`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md)
  object. The arguments are `reg`
  ([`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md))
  and `jobs`
  ([`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)).

- killJob:

  \[`function(reg, batch.id)`\]  
  Function to kill a job on the batch system. Make sure that you
  definitely kill the job! Return value is currently ignored. Must have
  the arguments `reg`
  ([`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md))
  and `batch.id` (`character(1)` as returned by `submitJob`). Note that
  there is a helper function
  [`cfKillJob`](https://batchtools.mlr-org.com/reference/cfKillJob.md)
  to repeatedly try to kill jobs. Set `killJob` to `NULL` if killing
  jobs cannot be supported.

- listJobsQueued:

  \[`function(reg)`\]  
  List all queued jobs on the batch system for the current user. Must
  return an character vector of batch ids, same format as they are
  returned by `submitJob`. Set `listJobsQueued` to `NULL` if listing of
  queued jobs is not supported.

- listJobsRunning:

  \[`function(reg)`\]  
  List all running jobs on the batch system for the current user. Must
  return an character vector of batch ids, same format as they are
  returned by `submitJob`. It does not matter if you return a few job
  ids too many (e.g. all for the current user instead of all for the
  current registry), but you have to include all relevant ones. Must
  have the argument are `reg`
  ([`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)).
  Set `listJobsRunning` to `NULL` if listing of running jobs is not
  supported.

- array.var:

  \[`character(1)`\]  
  Name of the environment variable set by the scheduler to identify IDs
  of job arrays. Default is `NA` for no array support.

- store.job.collection:

  \[`logical(1)`\]  
  Flag to indicate that the cluster function implementation of
  `submitJob` can not directly handle
  [`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
  objects. If set to `FALSE`, the
  [`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
  is serialized to the file system before submitting the job.

- store.job.files:

  \[`logical(1)`\]  
  Flag to indicate that job files need to be stored in the file
  directory. If set to `FALSE` (default), the job file is created in a
  temporary directory, otherwise (or if the debug mode is enabled) in
  the subdirectory `jobs` of the `file.dir`.

- scheduler.latency:

  \[`numeric(1)`\]  
  Time to sleep after important interactions with the scheduler to
  ensure a sane state. Currently only triggered after calling
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).

- fs.latency:

  \[`numeric(1)`\]  
  Expected maximum latency of the file system, in seconds. Set to a
  positive number for network file systems like NFS which enables more
  robust (but also more expensive) mechanisms to access files and
  directories. Usually safe to set to `0` to disable the heuristic, e.g.
  if you are working on a local file system.

- hooks:

  \[`list`\]  
  Named list of functions which will we called on certain events like
  “pre.submit” or “post.sync”. See
  [Hooks](https://batchtools.mlr-org.com/reference/runHook.md).

## See also

Other ClusterFunctions:
[`makeClusterFunctionsDocker()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsDocker.md),
[`makeClusterFunctionsHyperQueue()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsHyperQueue.md),
[`makeClusterFunctionsInteractive()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsInteractive.md),
[`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md),
[`makeClusterFunctionsMulticore()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsMulticore.md),
[`makeClusterFunctionsOpenLava()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsOpenLava.md),
[`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md),
[`makeClusterFunctionsSSH()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSSH.md),
[`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md),
[`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md),
[`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)

Other ClusterFunctionsHelper:
[`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md),
[`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md),
[`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md),
[`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md),
[`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md),
[`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)

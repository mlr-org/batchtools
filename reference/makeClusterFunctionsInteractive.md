# ClusterFunctions for Sequential Execution in the Running R Session

All jobs are executed sequentially using the current R process in which
[`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md)
is called. Thus, `submitJob` blocks the session until the job has
finished. The main use of this `ClusterFunctions` implementation is to
test and debug programs on a local computer.

Listing jobs returns an empty vector (as no jobs can be running when you
call this) and `killJob` is not implemented for the same reasons.

## Usage

``` r
makeClusterFunctionsInteractive(
  external = FALSE,
  write.logs = TRUE,
  fs.latency = 0
)
```

## Arguments

- external:

  \[`logical(1)`\]  
  If set to `TRUE`, jobs are started in a fresh R session instead of
  currently active but still waits for its termination. Default is
  `FALSE`.

- write.logs:

  \[`logical(1)`\]  
  Sink the output to log files. Turning logging off can increase the
  speed of calculations but makes it very difficult to debug. Default is
  `TRUE`.

- fs.latency:

  \[`numeric(1)`\]  
  Expected maximum latency of the file system, in seconds. Set to a
  positive number for network file systems like NFS which enables more
  robust (but also more expensive) mechanisms to access files and
  directories. Usually safe to set to `0` to disable the heuristic, e.g.
  if you are working on a local file system.

## Value

\[[`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)\].

## See also

Other ClusterFunctions:
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeClusterFunctionsDocker()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsDocker.md),
[`makeClusterFunctionsHyperQueue()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsHyperQueue.md),
[`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md),
[`makeClusterFunctionsMulticore()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsMulticore.md),
[`makeClusterFunctionsOpenLava()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsOpenLava.md),
[`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md),
[`makeClusterFunctionsSSH()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSSH.md),
[`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md),
[`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md),
[`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)

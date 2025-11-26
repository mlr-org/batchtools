# ClusterFunctions for HyperQueue

Cluster functions for HyperQueue
(<https://it4innovations.github.io/hyperqueue/stable/>).

Jobs are submitted via the HyperQueue CLI using `hq submit` and executed
by calling `Rscript -e "batchtools::doJobCollection(...)"`. The job name
is set to the job hash and logs are handled internally by batchtools.
Listing jobs uses `hq job list` and cancelling jobs uses
`hq job cancel`. A running HyperQueue server and workers are required.

## Usage

``` r
makeClusterFunctionsHyperQueue(scheduler.latency = 1, fs.latency = 65)
```

## Arguments

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

## Value

\[ClusterFunctions\].

## See also

Other ClusterFunctions:
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeClusterFunctionsDocker()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsDocker.md),
[`makeClusterFunctionsInteractive()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsInteractive.md),
[`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md),
[`makeClusterFunctionsMulticore()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsMulticore.md),
[`makeClusterFunctionsOpenLava()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsOpenLava.md),
[`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md),
[`makeClusterFunctionsSSH()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSSH.md),
[`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md),
[`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md),
[`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)

# ClusterFunctions for Parallel Multicore Execution

Jobs are spawned asynchronously using the functions `mcparallel` and
`mccollect` (both in parallel). Does not work on Windows, use
[`makeClusterFunctionsSocket`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md)
instead.

## Usage

``` r
makeClusterFunctionsMulticore(ncpus = NA_integer_, fs.latency = 0)
```

## Arguments

- ncpus:

  \[`integer(1)`\]  
  Number of CPUs. Default is to use all logical cores. The total number
  of cores "available" can be set via the option `mc.cores` and defaults
  to the heuristic implemented in
  [`detectCores`](https://rdrr.io/r/parallel/detectCores.html).

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
[`makeClusterFunctionsInteractive()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsInteractive.md),
[`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md),
[`makeClusterFunctionsOpenLava()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsOpenLava.md),
[`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md),
[`makeClusterFunctionsSSH()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSSH.md),
[`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md),
[`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md),
[`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)

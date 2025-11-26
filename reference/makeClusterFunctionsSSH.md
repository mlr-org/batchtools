# ClusterFunctions for Remote SSH Execution

Jobs are spawned by starting multiple R sessions via `Rscript` over SSH.
If the hostname of the
[`Worker`](https://batchtools.mlr-org.com/reference/Worker.md) equals
“localhost”, `Rscript` is called directly so that you do not need to
have an SSH client installed.

## Usage

``` r
makeClusterFunctionsSSH(workers, fs.latency = 65)
```

## Arguments

- workers:

  \[`list` of
  [`Worker`](https://batchtools.mlr-org.com/reference/Worker.md)\]  
  List of Workers as constructed with
  [`Worker`](https://batchtools.mlr-org.com/reference/Worker.md).

- fs.latency:

  \[`numeric(1)`\]  
  Expected maximum latency of the file system, in seconds. Set to a
  positive number for network file systems like NFS which enables more
  robust (but also more expensive) mechanisms to access files and
  directories. Usually safe to set to `0` to disable the heuristic, e.g.
  if you are working on a local file system.

## Value

\[[`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)\].

## Note

If you use a custom “.ssh/config” file, make sure your ProxyCommand
passes ‘-q’ to ssh, otherwise each output will end with the message
“Killed by signal 1” and this will break the communication with the
nodes.

## See also

Other ClusterFunctions:
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeClusterFunctionsDocker()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsDocker.md),
[`makeClusterFunctionsHyperQueue()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsHyperQueue.md),
[`makeClusterFunctionsInteractive()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsInteractive.md),
[`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md),
[`makeClusterFunctionsMulticore()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsMulticore.md),
[`makeClusterFunctionsOpenLava()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsOpenLava.md),
[`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md),
[`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md),
[`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md),
[`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# cluster functions for multicore execution on the local machine
makeClusterFunctionsSSH(list(Worker$new("localhost", ncpus = 2)))
} # }
```

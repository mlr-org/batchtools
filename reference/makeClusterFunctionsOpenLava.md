# ClusterFunctions for OpenLava

Cluster functions for OpenLava.

Job files are created based on the brew template `template`. This file
is processed with brew and then submitted to the queue using the `bsub`
command. Jobs are killed using the `bkill` command and the list of
running jobs is retrieved using `bjobs -u $USER -w`. The user must have
the appropriate privileges to submit, delete and list jobs on the
cluster (this is usually the case).

The template file can access all resources passed to
[`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md)
as well as all variables stored in the
[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md).
It is the template file's job to choose a queue for the job and handle
the desired resource allocations.

## Usage

``` r
makeClusterFunctionsOpenLava(
  template = "openlava",
  scheduler.latency = 1,
  fs.latency = 65
)
```

## Arguments

- template:

  \[`character(1)`\]  
  Either a path to a brew template file (with extension “tmpl”), or a
  short descriptive name enabling the following heuristic for the file
  lookup:

  1.  “batchtools.\[template\].tmpl” in the path specified by the
      environment variable “R_BATCHTOOLS_SEARCH_PATH”.

  2.  “batchtools.\[template\].tmpl” in the current working directory.

  3.  “\[template\].tmpl” in the user config directory (see
      [`user_config_dir`](https://rappdirs.r-lib.org/reference/user_data_dir.html));
      on linux this is usually “~/.config/batchtools/\[template\].tmpl”.

  4.  “.batchtools.\[template\].tmpl” in the home directory.

  5.  “\[template\].tmpl” in the package installation directory in the
      subfolder “templates”.

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

\[[`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)\].

## Note

Array jobs are currently not supported.

## See also

Other ClusterFunctions:
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeClusterFunctionsDocker()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsDocker.md),
[`makeClusterFunctionsHyperQueue()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsHyperQueue.md),
[`makeClusterFunctionsInteractive()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsInteractive.md),
[`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md),
[`makeClusterFunctionsMulticore()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsMulticore.md),
[`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md),
[`makeClusterFunctionsSSH()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSSH.md),
[`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md),
[`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md),
[`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)

# ClusterFunctions for Docker

Cluster functions for Docker/Docker Swarm
(<https://docs.docker.com/engine/swarm/>).

The `submitJob` function executes
`docker [docker.args] run --detach=true [image.args] [resources] [image] [cmd]`.
Arguments `docker.args`, `image.args` and `image` can be set on
construction. The `resources` part takes the named resources `ncpus` and
`memory` from
[`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md)
and maps them to the arguments `--cpu-shares` and `--memory` (in
Megabytes). The resource `threads` is mapped to the environment
variables “OMP_NUM_THREADS” and “OPENBLAS_NUM_THREADS”. To reliably
identify jobs in the swarm, jobs are labeled with
“batchtools=\[job.hash\]” and named using the current login name (label
“user”) and the job hash (label “batchtools”).

`listJobsRunning` uses `docker [docker.args] ps --format={{.ID}}` to
filter for running jobs.

`killJobs` uses `docker [docker.args] kill [batch.id]` to filter for
running jobs.

These cluster functions use a
[Hook](https://batchtools.mlr-org.com/reference/runHook.md) to remove
finished jobs before a new submit and every time the
[Registry](https://batchtools.mlr-org.com/reference/makeRegistry.md) is
synchronized (using
[`syncRegistry`](https://batchtools.mlr-org.com/reference/syncRegistry.md)).
This is currently required because docker does not remove terminated
containers automatically. Use
`docker ps -a --filter 'label=batchtools' --filter 'status=exited'` to
identify and remove terminated containers manually (or usa a cron job).

## Usage

``` r
makeClusterFunctionsDocker(
  image,
  docker.args = character(0L),
  image.args = character(0L),
  scheduler.latency = 1,
  fs.latency = 65
)
```

## Arguments

- image:

  \[`character(1)`\]  
  Name of the docker image to run.

- docker.args:

  \[`character`\]  
  Additional arguments passed to “docker” \*before\* the command (“run”,
  “ps” or “kill”) to execute (e.g., the docker host).

- image.args:

  \[`character`\]  
  Additional arguments passed to “docker run” (e.g., to define mounts or
  environment variables).

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

## See also

Other ClusterFunctions:
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
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

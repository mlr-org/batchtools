# Cluster Functions Helper to Kill Batch Jobs

This function is only intended for use in your own cluster functions
implementation.

Calls the OS command to kill a job via
[`system`](https://rdrr.io/r/base/system.html) like this: “cmd
batch.job.id”. If the command returns an exit code \> 0, the command is
repeated after a 1 second sleep `max.tries-1` times. If the command
failed in all tries, an error is generated.

## Usage

``` r
cfKillJob(
  reg,
  cmd,
  args = character(0L),
  max.tries = 3L,
  nodename = "localhost"
)
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

- cmd:

  \[`character(1)`\]  
  OS command, e.g. “qdel”.

- args:

  \[`character`\]  
  Arguments to `cmd`, including the batch id.

- max.tries:

  \[`integer(1)`\]  
  Number of total times to try execute the OS command in cases of
  failures. Default is `3`.

- nodename:

  \[`character(1)`\]  
  Name of the SSH node to run the command on. If set to “localhost”
  (default), the command is not piped through SSH.

## Value

`TRUE` on success. An exception is raised otherwise.

## See also

Other ClusterFunctionsHelper:
[`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md),
[`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md),
[`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md),
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md),
[`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)

# Cluster Functions Helper to Handle Unknown Errors

This function is only intended for use in your own cluster functions
implementation.

Simply constructs a
[`SubmitJobResult`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md)
object with status code 101, NA as batch id and an informative error
message containing the output of the OS command in `output`.

## Usage

``` r
cfHandleUnknownSubmitError(cmd, exit.code, output)
```

## Arguments

- cmd:

  \[`character(1)`\]  
  OS command used to submit the job, e.g. qsub.

- exit.code:

  \[`integer(1)`\]  
  Exit code of the OS command, should not be 0.

- output:

  \[`character`\]  
  Output of the OS command, hopefully an informative error message. If
  these are multiple lines in a vector, they are automatically joined.

## Value

\[[`SubmitJobResult`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md)\].

## See also

Other ClusterFunctionsHelper:
[`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md),
[`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md),
[`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md),
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md),
[`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)

# Create a SubmitJobResult

This function is only intended for use in your own cluster functions
implementation.

Use this function in your implementation of
[`makeClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)
to create a return value for the `submitJob` function.

## Usage

``` r
makeSubmitJobResult(
  status,
  batch.id,
  log.file = NA_character_,
  msg = NA_character_
)
```

## Arguments

- status:

  \[`integer(1)`\]  
  Launch status of job. 0 means success, codes between 1 and 100 are
  temporary errors and any error greater than 100 is a permanent
  failure.

- batch.id:

  \[[`character()`](https://rdrr.io/r/base/character.html)\]  
  Unique id of this job on batch system, as given by the batch system.
  Must be globally unique so that the job can be terminated using just
  this information. For array jobs, this may be a vector of length equal
  to the number of jobs in the array.

- log.file:

  \[[`character()`](https://rdrr.io/r/base/character.html)\]  
  Log file. If `NA`, defaults to `[job.hash].log`. Some cluster
  functions set this for array jobs.

- msg:

  \[`character(1)`\]  
  Optional error message in case `status` is not equal to 0. Default is
  “OK”, “TEMPERROR”, “ERROR”, depending on `status`.

## Value

\[`SubmitJobResult`\]. A list, containing `status`, `batch.id` and
`msg`.

## See also

Other ClusterFunctionsHelper:
[`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md),
[`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md),
[`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md),
[`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md),
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)

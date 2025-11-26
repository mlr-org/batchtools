# Cluster Functions Helper to Write Job Description Files

This function is only intended for use in your own cluster functions
implementation.

Calls brew silently on your template, any error will lead to an
exception. The file is stored at the same place as the corresponding job
file in the “jobs”-subdir of your files directory.

## Usage

``` r
cfBrewTemplate(reg, text, jc)
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

- text:

  \[`character(1)`\]  
  String ready to be brewed. See
  [`cfReadBrewTemplate`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md)
  to read a template from the file system.

- jc:

  \[[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)`)`\]  
  Will be used as environment to brew the template file in. See
  [`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
  for a list of all available variables.

## Value

\[`character(1)`\]. File path to brewed template file.

## See also

Other ClusterFunctionsHelper:
[`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md),
[`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md),
[`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md),
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md),
[`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)

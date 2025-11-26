# Cluster Functions Helper to Parse a Brew Template

This function is only intended for use in your own cluster functions
implementation.

This function is only intended for use in your own cluster functions
implementation. Simply reads your template file and returns it as a
character vector.

## Usage

``` r
cfReadBrewTemplate(template, comment.string = NA_character_)
```

## Arguments

- template:

  \[`character(1)`\]  
  Path to template file which is then passed to
  [`brew`](https://rdrr.io/pkg/brew/man/brew.html).

- comment.string:

  \[`character(1)`\]  
  Ignore lines starting with this string.

## Value

\[`character`\].

## See also

Other ClusterFunctionsHelper:
[`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md),
[`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md),
[`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md),
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md),
[`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)

# Run OS Commands on Local or Remote Machines

This is a helper function to run arbitrary OS commands on local or
remote machines. The interface is similar to
[`system2`](https://rdrr.io/r/base/system2.html), but it always returns
the exit status *and* the output.

## Usage

``` r
runOSCommand(
  sys.cmd,
  sys.args = character(0L),
  stdin = "",
  nodename = "localhost"
)
```

## Arguments

- sys.cmd:

  \[`character(1)`\]  
  Command to run.

- sys.args:

  \[`character`\]  
  Arguments for `sys.cmd`.

- stdin:

  \[`character(1)`\]  
  Argument passed to [`system2`](https://rdrr.io/r/base/system2.html).

- nodename:

  \[`character(1)`\]  
  Name of the SSH node to run the command on. If set to “localhost”
  (default), the command is not piped through SSH.

## Value

\[`named list`\] with “sys.cmd”, “sys.args”, “exit.code” (integer),
“output” (character).

## See also

Other ClusterFunctionsHelper:
[`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md),
[`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md),
[`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md),
[`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md),
[`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md),
[`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md)

## Examples

``` r
if (FALSE) { # \dontrun{
runOSCommand("ls")
runOSCommand("ls", "-al")
runOSCommand("notfound")
} # }
```

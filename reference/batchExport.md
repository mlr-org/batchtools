# Export Objects to the Slaves

Objects are saved in subdirectory “exports” of the “file.dir” of `reg`.
They are automatically loaded and placed in the global environment each
time the registry is loaded or a job collection is executed.

## Usage

``` r
batchExport(
  export = list(),
  unexport = character(0L),
  reg = getDefaultRegistry()
)
```

## Arguments

- export:

  \[`list`\]  
  Named list of objects to export.

- unexport:

  \[`character`\]  
  Vector of object names to unexport.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`data.table`\] with name and uri to the exported objects.

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'

# list exports
exports = batchExport(reg = tmp)
print(exports)
#> Empty data.table (0 rows and 2 cols): name,uri

# add a job and required exports
batchMap(function(x) x^2 + y + z, x = 1:3, reg = tmp)
#> Adding 3 jobs ...
exports = batchExport(export = list(y = 99, z = 1), reg = tmp)
#> Exporting new objects: 'y','z' ...
print(exports)
#>      name                                        uri
#>    <char>                                  <fs_path>
#> 1:      y /tmp/batchtools-example/reg/exports/PE.rds
#> 2:      z /tmp/batchtools-example/reg/exports/PI.rds

submitJobs(reg = tmp)
#> Submitting 3 jobs in 3 chunks using cluster functions 'Interactive' ...
waitForJobs(reg = tmp)
#> [1] TRUE
stopifnot(loadResult(1, reg = tmp) == 101)

# Un-export z
exports = batchExport(unexport = "z", reg = tmp)
#> Un-exporting exported objects: 'z' ...
print(exports)
#>      name                                        uri
#>    <char>                                  <fs_path>
#> 1:      y /tmp/batchtools-example/reg/exports/PE.rds
```

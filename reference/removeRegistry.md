# Remove a Registry from the File System

All files will be erased from the file system, including all results. If
you wish to remove only intermediate files, use
[`sweepRegistry`](https://batchtools.mlr-org.com/reference/sweepRegistry.md).

## Usage

``` r
removeRegistry(wait = 5, reg = getDefaultRegistry())
```

## Arguments

- wait:

  \[`numeric(1)`\]  
  Seconds to wait before proceeding. This is a safety measure to not
  accidentally remove your precious files. Set to 0 in non-interactive
  scripts to disable this precaution.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`character(1)`\]: Path of the deleted file directory.

## See also

Other Registry:
[`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md),
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md),
[`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
[`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md),
[`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md),
[`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
removeRegistry(0, tmp)
#> Recursively removing files in '/tmp/batchtools-example/reg' ...
```

# Synchronize the Registry

Parses update files written by the slaves to the file system and updates
the internal data base.

## Usage

``` r
syncRegistry(reg = getDefaultRegistry())
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`logical(1)`\]: `TRUE` if the state has changed, `FALSE` otherwise.

## See also

Other Registry:
[`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md),
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md),
[`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
[`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md),
[`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md),
[`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md)

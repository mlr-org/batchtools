# Remove All Jobs

Removes all jobs from a registry and calls
[`sweepRegistry`](https://batchtools.mlr-org.com/reference/sweepRegistry.md).

## Usage

``` r
clearRegistry(reg = getDefaultRegistry())
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## See also

Other Registry:
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md),
[`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
[`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md),
[`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md),
[`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md),
[`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)

# Check Consistency and Remove Obsolete Information

Canceled jobs and jobs submitted multiple times may leave stray files
behind. This function checks the registry for consistency and removes
obsolete files and redundant data base entries.

## Usage

``` r
sweepRegistry(reg = getDefaultRegistry())
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## See also

Other Registry:
[`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md),
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md),
[`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
[`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md),
[`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md),
[`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)

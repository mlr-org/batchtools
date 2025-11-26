# Store the Registy to the File System

Stores the registry on the file system in its “file.dir” (specified for
construction in
[`makeRegistry`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
can be accessed via `reg$file.dir`). This function is usually called
internally whenever needed.

## Usage

``` r
saveRegistry(reg = getDefaultRegistry())
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`logical(1)`\]: `TRUE` if the registry was saved, `FALSE` otherwise
(if the registry is read-only).

## See also

Other Registry:
[`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md),
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md),
[`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
[`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md),
[`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md),
[`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)

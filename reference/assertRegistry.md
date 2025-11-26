# assertRegistry

Assert that a given object is a `batchtools` registry. Additionally can
sync the registry, check if it is writeable, or check if jobs are
running. If any check fails, throws an error indicting the reason for
the failure.

## Usage

``` r
assertRegistry(
  reg,
  class = NULL,
  writeable = FALSE,
  sync = FALSE,
  running.ok = TRUE
)
```

## Arguments

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  The object asserted to be a `Registry`.

- class:

  \[`character(1)`\]  
  If `NULL` (default), `reg` must only inherit from class “Registry”.
  Otherwise check that `reg` is of class `class`. E.g., if set to
  “Registry”, a
  [`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)
  would not pass.

- writeable:

  \[`logical(1)`\]  
  Check if the registry is writeable.

- sync:

  \[`logical(1)`\]  
  Try to synchronize the registry by including pending results from the
  file system. See
  [`syncRegistry`](https://batchtools.mlr-org.com/reference/syncRegistry.md).

- running.ok:

  \[`logical(1)`\]  
  If `FALSE` throw an error if jobs associated with the registry are
  currently running.

## Value

`TRUE` invisibly.

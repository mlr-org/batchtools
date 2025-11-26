# Load the Result of a Single Job

Loads the result of a single job.

## Usage

``` r
loadResult(id, reg = getDefaultRegistry())
```

## Arguments

- id:

  \[`integer(1)` or `data.table`\]  
  Single integer to specify the job or a `data.table` with column
  `job.id` and exactly one row.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`ANY`\]. The stored result.

## See also

Other Results:
[`batchMapResults()`](https://batchtools.mlr-org.com/reference/batchMapResults.md),
[`reduceResults()`](https://batchtools.mlr-org.com/reference/reduceResults.md),
[`reduceResultsList()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)

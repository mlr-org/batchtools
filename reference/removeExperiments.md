# Remove Experiments

Remove Experiments from an
[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md).
This function automatically checks if any of the jobs to reset is either
pending or running. However, if the implemented heuristic fails, this
can lead to inconsistencies in the data base. Use with care while jobs
are running.

## Usage

``` r
removeExperiments(ids = NULL, reg = getDefaultRegistry())
```

## Arguments

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to no job. Invalid
  ids are ignored.

- reg:

  \[[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)\]  
  Registry. If not explicitly passed, uses the last created registry.

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
of removed job ids, invisibly.

## See also

Other Experiment:
[`addExperiments()`](https://batchtools.mlr-org.com/reference/addExperiments.md),
[`summarizeExperiments()`](https://batchtools.mlr-org.com/reference/summarizeExperiments.md)

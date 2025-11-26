# Quick Summary over Experiments

Returns a frequency table of defined experiments. See
[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)
for an example.

## Usage

``` r
summarizeExperiments(
  ids = NULL,
  by = c("problem", "algorithm"),
  reg = getDefaultRegistry()
)
```

## Arguments

- ids:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) or
  `integer`\]  
  A [`data.frame`](https://rdrr.io/r/base/data.frame.html) (or
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))
  with a column named “job.id”. Alternatively, you may also pass a
  vector of integerish job ids. If not set, defaults to all jobs.
  Invalid ids are ignored.

- by:

  \[`character`\]  
  Split the resulting table by columns of
  [`getJobPars`](https://batchtools.mlr-org.com/reference/getJobTable.md).

- reg:

  \[[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)\]  
  Registry. If not explicitly passed, uses the last created registry.

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
of frequencies.

## See also

Other Experiment:
[`addExperiments()`](https://batchtools.mlr-org.com/reference/addExperiments.md),
[`removeExperiments()`](https://batchtools.mlr-org.com/reference/removeExperiments.md)

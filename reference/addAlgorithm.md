# Define Algorithms for Experiments

Algorithms are functions which get the `data` part as well as the
problem instance (the return value of the function defined in
[`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md)) and
return an arbitrary R object.

This function serializes all components to the file system and registers
the algorithm in the
[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md).

`removeAlgorithm` removes all jobs from the registry which depend on the
specific algorithm. `reg$algorithms` holds the IDs of already defined
algorithms.

## Usage

``` r
addAlgorithm(name, fun = NULL, reg = getDefaultRegistry())

removeAlgorithms(name, reg = getDefaultRegistry())
```

## Arguments

- name:

  \[`character(1)`\]  
  Unique identifier for the algorithm.

- fun:

  \[`function`\]  
  The algorithm function. The static problem part is passed as “data”,
  the generated problem instance is passed as “instance” and the
  [`Job`](https://batchtools.mlr-org.com/reference/JobExperiment.md)/[`Experiment`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  as “job”. Therefore, your function must have the formal arguments
  “job”, “data” and “instance” (or dots `...`).

  If you do not provide a function, it defaults to a function which just
  returns the instance.

- reg:

  \[[`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)\]  
  Registry. If not explicitly passed, uses the last created registry.

## Value

\[`Algorithm`\]. Object of class “Algorithm”.

## See also

[`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md),
[`addExperiments`](https://batchtools.mlr-org.com/reference/addExperiments.md)

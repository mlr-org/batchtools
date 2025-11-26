# Trigger Evaluation of Custom Function

Hooks allow to trigger functions calls on specific events. They can be
specified via the
[`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)
and are triggered on the following events:

- `pre.sync`:

  `function(reg, fns, ...)`: Run before synchronizing the registry on
  the master. `fn` is the character vector of paths to the update files.

- `post.sync`:

  `function(reg, updates, ...)`: Run after synchronizing the registry on
  the master. `updates` is the data.table of processed updates.

- `pre.submit.job`:

  `function(reg, ...)`: Run before a job is successfully submitted to
  the scheduler on the master.

- `post.submit.job`:

  `function(reg, ...)`: Run after a job is successfully submitted to the
  scheduler on the master.

- `pre.submit`:

  `function(reg, ...)`: Run before any job is submitted to the
  scheduler.

- `post.submit`:

  `function(reg, ...)`: Run after a jobs are submitted to the schedule.

- `pre.do.collection`:

  `function(reg, reader, ...)`: Run before starting the job collection
  on the slave. `reader` is an internal cache object.

- `post.do.collection`:

  `function(reg, updates, reader, ...)`: Run after all jobs in the chunk
  are terminated on the slave. `updates` is a
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  of updates which will be merged with the
  [`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)
  by the master. `reader` is an internal cache object.

- `pre.kill`:

  `function(reg, ids, ...)`: Run before any job is killed.

- `post.kill`:

  `function(reg, ids, ...)`: Run after jobs are killed. `ids` is the
  return value of
  [`killJobs`](https://batchtools.mlr-org.com/reference/killJobs.md).

## Usage

``` r
runHook(obj, hook, ...)
```

## Arguments

- obj:

  \[[Registry](https://batchtools.mlr-org.com/reference/makeRegistry.md)
  \|
  [JobCollection](https://batchtools.mlr-org.com/reference/JobCollection.md)\]  
  Registry which contains the
  [ClusterFunctions](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)
  with element “hooks” or a
  [JobCollection](https://batchtools.mlr-org.com/reference/JobCollection.md)
  which holds the subset of functions which are executed remotely.

- hook:

  \[`character(1)`\]  
  ID of the hook as string.

- ...:

  \[ANY\]  
  Additional arguments passed to the function referenced by `hook`. See
  description.

## Value

Return value of the called function, or `NULL` if there is no hook with
the specified ID.

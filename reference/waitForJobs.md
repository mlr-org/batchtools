# Wait for Termination of Jobs

This function simply waits until all jobs are terminated.

## Usage

``` r
waitForJobs(
  ids = NULL,
  sleep = NULL,
  timeout = 604800,
  expire.after = NULL,
  stop.on.error = FALSE,
  stop.on.expire = FALSE,
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
  vector of integerish job ids. If not set, defaults to the return value
  of
  [`findSubmitted`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- sleep:

  \[`function(i)` \| `numeric(1)`\]  
  Parameter to control the duration to sleep between queries. You can
  pass an absolute numeric value in seconds or a `function(i)` which
  returns the number of seconds to sleep in the `i`-th iteration. If not
  provided (`NULL`), tries to read the value (number/function) from the
  configuration file (stored in `reg$sleep`) or defaults to a function
  with exponential backoff between 5 and 120 seconds.

- timeout:

  \[`numeric(1)`\]  
  After waiting `timeout` seconds, show a message and return `FALSE`.
  This argument may be required on some systems where, e.g., expired
  jobs or jobs on hold are problematic to detect. If you don't want a
  timeout, set this to `Inf`. Default is `604800` (one week).

- expire.after:

  \[`integer(1)`\]  
  Jobs count as “expired” if they are not found on the system but have
  not communicated back their results (or error message). This
  frequently happens on managed system if the scheduler kills a job
  because the job has hit the walltime or request more memory than
  reserved. On the other hand, network file systems often require
  several seconds for new files to be found, which can lead to false
  positives in the detection heuristic. `waitForJobs` treats such jobs
  as expired after they have not been detected on the system for
  `expire.after` iterations. If not provided (`NULL`), tries to read the
  value from the configuration file (stored in `reg$expire.after`), and
  finally defaults to `3`.

- stop.on.error:

  \[`logical(1)`\]  
  Immediately cancel if a job terminates with an error? Default is
  `FALSE`.

- stop.on.expire:

  \[`logical(1)`\]  
  Immediately cancel if jobs are detected to be expired? Default is
  `FALSE`. Expired jobs will then be ignored for the remainder of
  `waitForJobs()`.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`logical(1)`\]. Returns `TRUE` if all jobs terminated successfully and
`FALSE` if either the timeout is reached or at least one job terminated
with an exception or expired.

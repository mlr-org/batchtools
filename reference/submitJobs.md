# Submit Jobs to the Batch Systems

Submits defined jobs to the batch system.

After submitting the jobs, you can use
[`waitForJobs`](https://batchtools.mlr-org.com/reference/waitForJobs.md)
to wait for the termination of jobs or call
[`reduceResultsList`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)/[`reduceResults`](https://batchtools.mlr-org.com/reference/reduceResults.md)
to collect partial results. The progress can be monitored with
[`getStatus`](https://batchtools.mlr-org.com/reference/getStatus.md).

## Usage

``` r
submitJobs(
  ids = NULL,
  resources = list(),
  sleep = NULL,
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
  [`findNotSubmitted`](https://batchtools.mlr-org.com/reference/findJobs.md).
  Invalid ids are ignored.

- resources:

  \[`named list`\]  
  Computational resources for the jobs to submit. The actual elements of
  this list (e.g. something like “walltime” or “nodes”) depend on your
  template file, exceptions are outlined in the section 'Resources'.
  Default settings for a system can be set in the configuration file by
  defining the named list `default.resources`. Note that these settings
  are merged by name, e.g. merging `list(walltime = 300)` into
  `list(walltime = 400, memory = 512)` will result in
  `list(walltime = 300, memory = 512)`. Same holds for individual job
  resources passed as additional column of `ids` (c.f. section
  'Resources').

- sleep:

  \[`function(i)` \| `numeric(1)`\]  
  Parameter to control the duration to sleep between temporary errors.
  You can pass an absolute numeric value in seconds or a `function(i)`
  which returns the number of seconds to sleep in the `i`-th iteration
  between temporary errors. If not provided (`NULL`), tries to read the
  value (number/function) from the configuration file (stored in
  `reg$sleep`) or defaults to a function with exponential backoff
  between 5 and 120 seconds.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with columns “job.id” and “chunk”.

## Note

If you a large number of jobs, disabling the progress bar
(`options(batchtools.progress = FALSE)`) can significantly increase the
performance of `submitJobs`.

## Resources

You can pass arbitrary resources to `submitJobs()` which then are
available in the cluster function template. Some resources' names are
standardized and it is good practice to stick to the following
nomenclature to avoid confusion:

- walltime::

  Upper time limit in seconds for jobs before they get killed by the
  scheduler. Can be passed as additional column as part of `ids` to set
  per-job resources.

- memory::

  Memory limit in Mb. If jobs exceed this limit, they are usually killed
  by the scheduler. Can be passed as additional column as part of `ids`
  to set per-job resources.

- ncpus::

  Number of (physical) CPUs to use on the slave. Can be passed as
  additional column as part of `ids` to set per-job resources.

- omp.threads::

  Number of threads to use via OpenMP. Used to set environment variable
  “OMP_NUM_THREADS”. Can be passed as additional column as part of `ids`
  to set per-job resources.

- pp.size::

  Maximum size of the pointer protection stack, see
  [`Memory`](https://rdrr.io/r/base/Memory.html).

- blas.threads::

  Number of threads to use for the BLAS backend. Used to set environment
  variables “MKL_NUM_THREADS” and “OPENBLAS_NUM_THREADS”. Can be passed
  as additional column as part of `ids` to set per-job resources.

- measure.memory::

  Enable memory measurement for jobs. Comes with a small runtime
  overhead.

- chunks.as.arrayjobs::

  Execute chunks as array jobs.

- pm.backend::

  Start a parallelMap backend on the slave.

- foreach.backend::

  Start a foreach backend on the slave.

- clusters::

  Resource used for Slurm to select the set of clusters to run
  `sbatch`/`squeue`/`scancel` on.

## Chunking of Jobs

Multiple jobs can be grouped (chunked) together to be executed
sequentially on the batch system as a single batch job. This is
especially useful to avoid overburding the scheduler by submitting
thousands of jobs simultaneously. To chunk jobs together, job ids must
be provided as `data.frame` with columns “job.id” and “chunk” (integer).
All jobs with the same chunk number will be executed sequentially inside
the same batch job. The utility functions
[`chunk`](https://batchtools.mlr-org.com/reference/chunk.md),
[`binpack`](https://batchtools.mlr-org.com/reference/chunk.md) and
[`lpt`](https://batchtools.mlr-org.com/reference/chunk.md) can assist in
grouping jobs.

## Array Jobs

If your cluster supports array jobs, you can set the resource
`chunks.as.arrayjobs` to `TRUE` in order to execute chunks as job arrays
on the cluster. For each chunk of size `n`, batchtools creates a
[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
of (possibly heterogeneous) jobs which is submitted to the scheduler as
a single array job with `n` repetitions. For each repetition, the
`JobCollection` is first read from the file system, then subsetted to
the `i`-th job using the environment variable
`reg$cluster.functions$array.var` (depending on the cluster backend,
defined automatically) and finally executed.

## Order of Submission

Jobs are submitted in the order of chunks, i.e. jobs which have chunk
number `sort(unique(ids$chunk))[1]` first, then jobs with chunk number
`sort(unique(ids$chunk))[2]` and so on. If no chunks are provided, jobs
are submitted in the order of `ids$job.id`.

## Limiting the Number of Jobs

If requested, `submitJobs` tries to limit the number of concurrent jobs
of the user by waiting until jobs terminate before submitting new ones.
This can be controlled by setting “max.concurrent.jobs” in the
configuration file (see
[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md))
or by setting the resource “max.concurrent.jobs” to the maximum number
of jobs to run simultaneously. If both are set, the setting via the
resource takes precedence over the setting in the configuration.

## Measuring Memory

Setting the resource `measure.memory` to `TRUE` turns on memory
measurement: [`gc`](https://rdrr.io/r/base/gc.html) is called directly
before and after the job and the difference is stored in the internal
database. Note that this is just a rough estimate and does neither work
reliably for external code like C/C++ nor in combination with threading.

## Inner Parallelization

Inner parallelization is typically done via threading, sockets or MPI.
Two backends are supported to assist in setting up inner
parallelization.

The first package is parallelMap. If you set the resource “pm.backend”
to “multicore”, “socket” or “mpi”,
[`parallelStart`](https://parallelmap.mlr-org.com/reference/parallelStart.html)
is called on the slave before the first job in the chunk is started and
[`parallelStop`](https://parallelmap.mlr-org.com/reference/parallelStop.html)
is called after the last job terminated. This way, the resources for
inner parallelization can be set and get automatically stored just like
other computational resources. The function provided by the user just
has to call
[`parallelMap`](https://parallelmap.mlr-org.com/reference/parallelMap.html)
to start parallelization using the preconfigured backend.

To control the number of CPUs, you have to set the resource `ncpus`.
Otherwise `ncpus` defaults to the number of available CPUs (as reported
by (see [`detectCores`](https://rdrr.io/r/parallel/detectCores.html)))
on the executing machine for multicore and socket mode and defaults to
the return value of
[`mpi.universe.size`](https://rdrr.io/pkg/Rmpi/man/mpi.universe.size.html)`-1`
for MPI. Your template must be set up to handle the parallelization,
e.g. request the right number of CPUs or start R with `mpirun`. You may
pass further options like `level` to
[`parallelStart`](https://parallelmap.mlr-org.com/reference/parallelStart.html)
via the named list “pm.opts”.

The second supported parallelization backend is foreach. If you set the
resource “foreach.backend” to “seq” (sequential mode), “parallel”
(doParallel) or “mpi” (doMPI), the requested foreach backend is
automatically registered on the slave. Again, the resource `ncpus` is
used to determine the number of CPUs.

Neither the namespace of parallelMap nor the namespace foreach are
attached. You have to do this manually via
[`library`](https://rdrr.io/r/base/library.html) or let the registry
load the packages for you.

## Examples

``` r
### Example 1: Submit subsets of jobs
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg1' using cluster functions 'Interactive'

# toy function which fails if x is even and an input file does not exists
fun = function(x, fn) if (x %% 2 == 0 && !file.exists(fn)) stop("file not found") else x

# define jobs via batchMap
fn = tempfile()
ids = batchMap(fun, 1:20, reg = tmp, fn = fn)
#> Adding 20 jobs ...

# submit some jobs
ids = 1:10
submitJobs(ids, reg = tmp)
#> Submitting 10 jobs in 10 chunks using cluster functions 'Interactive' ...
#> Error in (function (x, fn)  : file not found
#> Error in (function (x, fn)  : file not found
#> Error in (function (x, fn)  : file not found
#> Error in (function (x, fn)  : file not found
#> Error in (function (x, fn)  : file not found
waitForJobs(ids, reg = tmp)
#> [1] FALSE
getStatus(reg = tmp)
#> Status for 20 jobs at 2025-11-26 10:23:40:
#>   Submitted    : 10 ( 50.0%)
#>   -- Queued    :  0 (  0.0%)
#>   -- Started   : 10 ( 50.0%)
#>   ---- Running :  0 (  0.0%)
#>   ---- Done    :  5 ( 25.0%)
#>   ---- Error   :  5 ( 25.0%)
#>   ---- Expired :  0 (  0.0%)

# create the required file and re-submit failed jobs
file.create(fn)
#> [1] TRUE
submitJobs(findErrors(ids, reg = tmp), reg = tmp)
#> Submitting 5 jobs in 5 chunks using cluster functions 'Interactive' ...
getStatus(reg = tmp)
#> Status for 20 jobs at 2025-11-26 10:23:41:
#>   Submitted    : 10 ( 50.0%)
#>   -- Queued    :  0 (  0.0%)
#>   -- Started   : 10 ( 50.0%)
#>   ---- Running :  0 (  0.0%)
#>   ---- Done    : 10 ( 50.0%)
#>   ---- Error   :  0 (  0.0%)
#>   ---- Expired :  0 (  0.0%)

# submit remaining jobs which have not yet been submitted
ids = findNotSubmitted(reg = tmp)
submitJobs(ids, reg = tmp)
#> Submitting 10 jobs in 10 chunks using cluster functions 'Interactive' ...
getStatus(reg = tmp)
#> Status for 20 jobs at 2025-11-26 10:23:41:
#>   Submitted    : 20 (100.0%)
#>   -- Queued    :  0 (  0.0%)
#>   -- Started   : 20 (100.0%)
#>   ---- Running :  0 (  0.0%)
#>   ---- Done    : 20 (100.0%)
#>   ---- Error   :  0 (  0.0%)
#>   ---- Expired :  0 (  0.0%)

# collect results
reduceResultsList(reg = tmp)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 2
#> 
#> [[3]]
#> [1] 3
#> 
#> [[4]]
#> [1] 4
#> 
#> [[5]]
#> [1] 5
#> 
#> [[6]]
#> [1] 6
#> 
#> [[7]]
#> [1] 7
#> 
#> [[8]]
#> [1] 8
#> 
#> [[9]]
#> [1] 9
#> 
#> [[10]]
#> [1] 10
#> 
#> [[11]]
#> [1] 11
#> 
#> [[12]]
#> [1] 12
#> 
#> [[13]]
#> [1] 13
#> 
#> [[14]]
#> [1] 14
#> 
#> [[15]]
#> [1] 15
#> 
#> [[16]]
#> [1] 16
#> 
#> [[17]]
#> [1] 17
#> 
#> [[18]]
#> [1] 18
#> 
#> [[19]]
#> [1] 19
#> 
#> [[20]]
#> [1] 20
#> 

### Example 2: Using memory measurement
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg2' using cluster functions 'Interactive'

# Toy function which creates a large matrix and returns the column sums
fun = function(n, p) colMeans(matrix(runif(n*p), n, p))

# Arguments to fun:
args = data.table::CJ(n = c(1e4, 1e5), p = c(10, 50)) # like expand.grid()
print(args)
#> Key: <n, p>
#>        n     p
#>    <num> <num>
#> 1: 1e+04    10
#> 2: 1e+04    50
#> 3: 1e+05    10
#> 4: 1e+05    50

# Map function to create jobs
ids = batchMap(fun, args = args, reg = tmp)
#> Adding 4 jobs ...

# Set resources: enable memory measurement
res = list(measure.memory = TRUE)

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = tmp)
#> Submitting 4 jobs in 4 chunks using cluster functions 'Interactive' ...

# Retrive information about memory, combine with parameters
info = ijoin(getJobStatus(reg = tmp)[, .(job.id, mem.used)], getJobPars(reg = tmp))
print(unwrap(info))
#> Key: <job.id>
#>    job.id mem.used     n     p
#>     <int>    <num> <num> <num>
#> 1:      1 162.9000 1e+04    10
#> 2:      2 162.9008 1e+04    50
#> 3:      3 162.9006 1e+05    10
#> 4:      4 162.9010 1e+05    50

# Combine job info with results -> each job is aggregated using mean()
unwrap(ijoin(info, reduceResultsDataTable(fun = function(res) list(res = mean(res)), reg = tmp)))
#> Key: <job.id>
#>    job.id mem.used     n     p       res
#>     <int>    <num> <num> <num>     <num>
#> 1:      1 162.9000 1e+04    10 0.4974659
#> 2:      2 162.9008 1e+04    50 0.4999527
#> 3:      3 162.9006 1e+05    10 0.4996599
#> 4:      4 162.9010 1e+05    50 0.5000197

### Example 3: Multicore execution on the slave
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg3' using cluster functions 'Interactive'

# Function which sleeps 10 seconds, i-times
f = function(i) {
  parallelMap::parallelMap(Sys.sleep, rep(10, i))
}

# Create one job with parameter i=4
ids = batchMap(f, i = 4, reg = tmp)
#> Adding 1 jobs ...

# Set resources: Use parallelMap in multicore mode with 4 CPUs
# batchtools internally loads the namespace of parallelMap and then
# calls parallelStart() before the job and parallelStop() right
# after the job last job in the chunk terminated.
res = list(pm.backend = "multicore", ncpus = 4)

if (FALSE) { # \dontrun{
# Submit both jobs and wait for them
submitJobs(resources = res, reg = tmp)
waitForJobs(reg = tmp)

# If successfull, the running time should be ~10s
getJobTable(reg = tmp)[, .(job.id, time.running)]

# There should also be a note in the log:
grepLogs(pattern = "parallelMap", reg = tmp)
} # }
```

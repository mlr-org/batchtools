# Changelog

## batchtools 0.9.18

CRAN release: 2025-08-20

- Fixed CRAN issues with documentation

## batchtools 0.9.17

CRAN release: 2023-04-20

- Fixed a bug in the finalizer of `ClusterFunctionsMulticore`.

## batchtools 0.9.16

CRAN release: 2023-02-03

- Fixed a bug in
  [`addExperiments()`](https://batchtools.mlr-org.com/reference/addExperiments.md)
  in combination with combination method `"bind"` and repls \> 1 where
  experiments have been duplicated.
- [`addExperiments()`](https://batchtools.mlr-org.com/reference/addExperiments.md)
  now also accepts a vector of replications (instead of a single scalar
  value) for argument `repls`.
- Improved handling of jobs in `ClusterFunctionsSlurm`.
- Fixed a bug in
  [`waitForJobs()`](https://batchtools.mlr-org.com/reference/waitForJobs.md)
- Fixed some assertions.

## batchtools 0.9.15

CRAN release: 2021-01-11

- Maintenance update.

## batchtools 0.9.14

CRAN release: 2020-10-21

- [`batchMap()`](https://batchtools.mlr-org.com/reference/batchMap.md)
  now supports unnamed `more.args`.
- Exports are now assigned with
  [`delayedAssign()`](https://rdrr.io/r/base/delayedAssign.html).
- Fix an option in the LSF template.

## batchtools 0.9.13

CRAN release: 2020-03-19

- Maintenance release for R-4.0.0.

## batchtools 0.9.12

CRAN release: 2020-01-10

- Moved `data.table` from `Depends` to `Imports`. User scripts might
  need to explicitly attach `data.table` via
  [`library()`](https://rdrr.io/r/base/library.html) now.
- Fixes for `ClusterFunctionsMulticore`.
- Removed a workaround for
  [`system2()`](https://rdrr.io/r/base/system2.html) for R-devel (to be
  released as R-4.0.0).
- New configuration option `compress` to select the compression
  algorithm (passed down to
  [`saveRDS()`](https://rdrr.io/r/base/readRDS.html)).

## batchtools 0.9.11

CRAN release: 2018-08-16

- Removed deprecated function `chunkIds()`.
- New default for argument `fs.timeout` in the cluster function
  constructor is `0` (was `NA` before).
- Fixed a unit test for OSX.
- Improved stability and documentation.
- Fixed memory usage calculation.

## batchtools 0.9.10

CRAN release: 2018-05-19

- Exported functions
  [`findConfFile()`](https://batchtools.mlr-org.com/reference/findConfFile.md)
  and
  [`findTemplateFile()`](https://batchtools.mlr-org.com/reference/findTemplateFile.md).
- Dropped support for providing a template file directly as string. A
  valid file is now always required.
- Fixed writing to `TMPDIR` instead of the R session’s temporary
  directory.

## batchtools 0.9.9

CRAN release: 2018-05-14

- RDS files are explicitly stored in version 2 to ensure backward
  compatibility with R versions prior to 3.5.0.
- Package `fs` is now used internally for all file system operations.
- Support for per-site configuration files and templates to be set up by
  system administrators.
- The print of
  [`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md)
  now includes a time stamp.
- [`chunk()`](https://batchtools.mlr-org.com/reference/chunk.md) now
  optionally shuffles the ids before chunking.
- Support for setting per-job resources in
  [`submitJobs()`](https://batchtools.mlr-org.com/reference/submitJobs.md).
- Example templates now include resources for `blas.threads` and
  `omp.threads`.
- Some bug fixes regarding read-only registries.

## batchtools 0.9.8

CRAN release: 2017-12-15

- Renamed column “memory” in the status table to “mem.used” to avoid
  name clashes with the resource specification.
- Exported function
  [`assertRegistry()`](https://batchtools.mlr-org.com/reference/assertRegistry.md).
- New function
  [`unwrap()`](https://batchtools.mlr-org.com/reference/unwrap.md) as
  alias to
  [`flatten()`](https://batchtools.mlr-org.com/reference/unwrap.md). The
  latter causes a name clash with package `purrr` and will be deprecated
  in a future version.
- Registries now contain a unique hash which is updated each time the
  registry is altered. Can be utilized to invalidate caches, e.g. the
  cache of knitr.

## batchtools 0.9.7

CRAN release: 2017-11-15

- Added a workaround for a test to be compatible with testthat v2.0.0.
- Better and more customizable handling of expired jobs in
  [`waitForJobs()`](https://batchtools.mlr-org.com/reference/waitForJobs.md).
- Package `foreach` is now supported for nested parallelization as an
  alternative to `parallelMap`.
- Depreciated argument flatten has been removed.
- New helper function
  [`flatten()`](https://batchtools.mlr-org.com/reference/unwrap.md) to
  manually unnest/unwrap lists in data frames.
- Removed functions `getProblemIds()` and `getAlgorithmIds()`. Instead,
  you can just access `reg$problems` or `reg$algorithms`, respectively.
- The number of the maximum concurrent jobs can now also be controlled
  via setting resources.
- Internal data base changes to speed up some operations. Old registries
  are updated on first load by
  [`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md).
- Fixed a bug where the sleep mechanism between queries was not working.
- Fixed a bug where submit errors on SLURM and TORQUE were not detected
  as temporary.

## batchtools 0.9.6

CRAN release: 2017-09-06

- Fixed a bug where the wrong problem was retrieved from the cache. This
  was only triggered for chunked jobs in combination with an
  `ExperimentRegistry`.

## batchtools 0.9.5

CRAN release: 2017-08-18

- Added a missing routine to upgrade registries created with batchtools
  prior to v0.9.3.
- Fixed a bug where the registry could not be synced if jobs failed
  during initialization
  ([\#135](https://github.com/mlr-org/batchtools/issues/135)).
- The sleep duration for
  [`waitForJobs()`](https://batchtools.mlr-org.com/reference/waitForJobs.md)
  and
  [`submitJobs()`](https://batchtools.mlr-org.com/reference/submitJobs.md)
  can now be set via the configuration file.
- A new heuristic will try to detect if the registry has been altered by
  a simultaneously running R session. If this is detected, the registry
  in the current session will be set to a read-only state.
- [`waitForJobs()`](https://batchtools.mlr-org.com/reference/waitForJobs.md)
  has been reworked to allow control over the heuristic to detect
  expired jobs. Jobs are treated as expired if they have been submitted
  but are not detected on the system for `expire.after` iterations
  (default 3 iterations, before 1 iteration).
- New argument `writeable` for
  [`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md)
  to allow loading registries explicitly as read-only.
- Removed argument `update.paths` from
  [`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md).
  Paths are always updated, but the registry on the file system remains
  unchanged unless loaded in read-write mode.
- `ClusterFunctionsSlurm` now come with an experimental nodename
  argument. If set, all communication with the master is handled via SSH
  which effectively allows you to submit jobs from your local machine
  instead of the head node. Note that mounting the file system (e.g.,
  via SSHFS) is mandatory.

## batchtools 0.9.4

CRAN release: 2017-08-07

- Fixed handling of `file.dir` with special chars like whitespace.
- All backward slashes will now be converted to forward slashes on
  windows.
- Fixed order of arguments in
  [`findExperiments()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  (argument `ids` is now first).
- Removed code to upgrade registries created with versions prior to
  v0.9.0 (first CRAN release).
- [`addExperiments()`](https://batchtools.mlr-org.com/reference/addExperiments.md)
  now warns if a design is passed as `data.frame` with factor columns
  and `stringsAsFactors` is `TRUE`.
- Added functions
  [`setJobNames()`](https://batchtools.mlr-org.com/reference/JobNames.md)
  and
  [`getJobNames()`](https://batchtools.mlr-org.com/reference/JobNames.md)
  to control the name of jobs on batch systems. Templates should be
  adapted to use `job.name` instead of `job.hash` for naming.
- Argument `flatten` of
  [`getJobResources()`](https://batchtools.mlr-org.com/reference/getJobTable.md),
  [`getJobPars()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  and
  [`getJobTable()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  is deprecated and will be removed. Future versions of the functions
  will behave like `flatten` is set to `FALSE` explicitly. Single
  resources/parameters must be extracted manually (or with
  `tidyr::unnest()`).

## batchtools 0.9.3

CRAN release: 2017-04-21

- Running jobs now are also included while querying for status
  “started”. This affects
  [`findStarted()`](https://batchtools.mlr-org.com/reference/findJobs.md),
  [`findNotStarted()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  and
  [`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md).
- [`findExperiments()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  now performs an exact string match (instead of matching substrings)
  for patterns specified via `prob.name` and `algo.name`. For substring
  matching, use `prob.pattern` or `algo.pattern`, respectively.
- Changed arguments for
  [`reduceResultsDataTable()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
  - Removed `fill`, now is always `TRUE`
  - Introduced `flatten` to control if the result should be represented
    as a column of lists or flattened as separate columns. Defaults to a
    backward-compatible heuristic, similar to `getJobPars`.
- Improved heuristic to lookup template files. Templates shipped with
  the package can now be used by providing just the file name (w/o
  extension).
- Updated CITATION

## batchtools 0.9.2

CRAN release: 2017-02-20

- Full support for array jobs on Slurm and TORQUE.
- Array jobs have been disabled for SGE and LSF (due to missing
  information about the output format) but will be re-enable in a future
  release. Note that the variable `n.array.jobs` has been removed from
  `JobCollection` in favor of the new variable `array.jobs` (logical).
- [`findExperiments()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  now has two additional arguments to match using regular expressions.
  The possibility to prefix a string with “~” to enable regular
  expression matching has been removed.
- New function
  [`batchReduce()`](https://batchtools.mlr-org.com/reference/batchReduce.md).
- New function
  [`estimateRuntimes()`](https://batchtools.mlr-org.com/reference/estimateRuntimes.md).
- New function
  [`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md).
- Missing result files are now handled more consistently, raising an
  exception in its defaults if the result is not available. The argument
  `missing.val` has been added to
  [`reduceResultsList()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
  and
  [`reduceResultsDataTable()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
  and removed from
  [`loadResult()`](https://batchtools.mlr-org.com/reference/loadResult.md)
  and
  [`batchMapResults()`](https://batchtools.mlr-org.com/reference/batchMapResults.md).
- Timestamps are now stored with sub-second accuracy.
- Renamed Torque to TORQUE. This especially affects the constructor
  `makeClusterFunctionsTorque` which now must be called via
  [`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)
- `chunkIds()` has been deprecated. Use
  [`chunk()`](https://batchtools.mlr-org.com/reference/chunk.md),
  [`lpt()`](https://batchtools.mlr-org.com/reference/chunk.md) or
  [`binpack()`](https://batchtools.mlr-org.com/reference/chunk.md)
  instead.
- Fixed listing of jobs for `ClusterFunctionsLSF` and
  `ClusterFunctionsOpenLava` (thanks to
  [@phaverty](https://github.com/phaverty)).
- Job hashes are now prefixed with the literal string ‘job’ to ensure
  they start with a letter as required by some SGE systems.
- Fixed handling of `NULL` results in
  [`reduceResultsList()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
- Fixed key lookup heuristic join functions.
- Fixed a bug where
  [`getJobTable()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  returned `difftimes` with the wrong unit (e.g., in minutes instead of
  seconds).
- Deactivated swap allocation for `ClusterFunctionsDocker`.
- The package is now more patient while communicating with the scheduler
  or file system by using a timeout-based approach. This should make the
  package more reliable and robust under heavy load.

## batchtools 0.9.0

CRAN release: 2016-11-08

Initial CRAN release. See the vignette for a brief comparison with
[BatchJobs](https://cran.r-project.org/package=BatchJobs)/[BatchExperiments](https://cran.r-project.org/package=BatchExperiments).

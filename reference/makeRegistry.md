# Registry Constructor

`makeRegistry` constructs the inter-communication object for all
functions in `batchtools`. All communication transactions are processed
via the file system: All information required to run a job is stored as
[`JobCollection`](https://batchtools.mlr-org.com/reference/JobCollection.md)
in a file in the a subdirectory of the `file.dir` directory. Each jobs
stores its results as well as computational status information (start
time, end time, error message, ...) also on the file system which is
regular merged parsed by the master using
[`syncRegistry`](https://batchtools.mlr-org.com/reference/syncRegistry.md).
After integrating the new information into the Registry, the Registry is
serialized to the file system via
[`saveRegistry`](https://batchtools.mlr-org.com/reference/saveRegistry.md).
Both
[`syncRegistry`](https://batchtools.mlr-org.com/reference/syncRegistry.md)
and
[`saveRegistry`](https://batchtools.mlr-org.com/reference/saveRegistry.md)
are called whenever required internally. Therefore it should be safe to
quit the R session at any time. Work can later be resumed by calling
[`loadRegistry`](https://batchtools.mlr-org.com/reference/loadRegistry.md)
which de-serializes the registry from the file system.

The registry created last is saved in the package namespace (unless
`make.default` is set to `FALSE`) and can be retrieved via
[`getDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md).

Canceled jobs and jobs submitted multiple times may leave stray files
behind. These can be swept using
[`sweepRegistry`](https://batchtools.mlr-org.com/reference/sweepRegistry.md).
[`clearRegistry`](https://batchtools.mlr-org.com/reference/clearRegistry.md)
completely erases all jobs from a registry, including log files and
results, and thus allows you to start over.

## Usage

``` r
makeRegistry(
  file.dir = "registry",
  work.dir = getwd(),
  conf.file = findConfFile(),
  packages = character(0L),
  namespaces = character(0L),
  source = character(0L),
  load = character(0L),
  seed = NULL,
  make.default = TRUE
)
```

## Arguments

- file.dir:

  \[`character(1)`\]  
  Path where all files of the registry are saved. Default is directory
  “registry” in the current working directory. The provided path will
  get normalized unless it is given relative to the home directory
  (i.e., starting with “~”). Note that some templates do not handle
  relative paths well.

  If you pass `NA`, a temporary directory will be used. This way, you
  can create disposable registries for
  [`btlapply`](https://batchtools.mlr-org.com/reference/btlapply.md) or
  examples. By default, the temporary directory
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) will be used. If
  you want to use another directory, e.g. a directory which is shared
  between nodes, you can set it in your configuration file by setting
  the variable `temp.dir`.

- work.dir:

  \[`character(1)`\]  
  Working directory for R process for running jobs. Defaults to the
  working directory currently set during Registry construction (see
  [`getwd`](https://rdrr.io/r/base/getwd.html)). `loadRegistry` uses the
  stored `work.dir`, but you may also explicitly overwrite it, e.g.,
  after switching to another system.

  The provided path will get normalized unless it is given relative to
  the home directory (i.e., starting with “~”). Note that some templates
  do not handle relative paths well.

- conf.file:

  \[`character(1)`\]  
  Path to a configuration file which is sourced while the registry is
  created. In the configuration file you can define how batchtools
  interacts with the system via
  [`ClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md).
  Separating the configuration of the underlying host system from the R
  code allows to easily move computation to another site.

  The file lookup is implemented in the internal (but exported) function
  `findConfFile` which returns the first file found of the following
  candidates:

  1.  File “batchtools.conf.R” in the path specified by the environment
      variable “R_BATCHTOOLS_SEARCH_PATH”.

  2.  File “batchtools.conf.R” in the current working directory.

  3.  File “config.R” in the user configuration directory as reported by
      `rappdirs::user_config_dir("batchtools", expand = FALSE)`
      (depending on OS, e.g., on linux this usually resolves to
      “~/.config/batchtools/config.R”).

  4.  “.batchtools.conf.R” in the home directory (“~”).

  5.  “config.R” in the site config directory as reported by
      `rappdirs::site_config_dir("batchtools")` (depending on OS). This
      file can be used for admins to set sane defaults for a computation
      site.

  Set to `NA` if you want to suppress reading any configuration file. If
  a configuration file is found, it gets sourced inside the environment
  of the registry after the defaults for all variables are set.
  Therefore you can set and overwrite slots, e.g.
  `default.resources = list(walltime = 3600)` to set default resources
  or “max.concurrent.jobs” to limit the number of jobs allowed to run
  simultaneously on the system.

- packages:

  \[`character`\]  
  Packages that will always be loaded on each node. Uses
  [`require`](https://rdrr.io/r/base/library.html) internally. Default
  is `character(0)`.

- namespaces:

  \[`character`\]  
  Same as `packages`, but the packages will not be attached. Uses
  [`requireNamespace`](https://rdrr.io/r/base/ns-load.html) internally.
  Default is `character(0)`.

- source:

  \[`character`\]  
  Files which should be sourced on the slaves prior to executing a job.
  Calls [`sys.source`](https://rdrr.io/r/base/sys.source.html) using the
  [`.GlobalEnv`](https://rdrr.io/r/base/environment.html).

- load:

  \[`character`\]  
  Files which should be loaded on the slaves prior to executing a job.
  Calls [`load`](https://rdrr.io/r/base/load.html) using the
  [`.GlobalEnv`](https://rdrr.io/r/base/environment.html).

- seed:

  \[`integer(1)`\]  
  Start seed for jobs. Each job uses the (`seed` + `job.id`) as seed.
  Default is a random integer between 1 and 32768. Note that there is an
  additional seeding mechanism to synchronize instantiation of
  [`Problem`](https://batchtools.mlr-org.com/reference/addProblem.md)s
  in a
  [`ExperimentRegistry`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md).

- make.default:

  \[`logical(1)`\]  
  If set to `TRUE`, the created registry is saved inside the package
  namespace and acts as default registry. You might want to switch this
  off if you work with multiple registries simultaneously. Default is
  `TRUE`.

## Value

\[`environment`\] of class “Registry” with the following slots:

- `file.dir` \[path\]::

  File directory.

- `work.dir` \[path\]::

  Working directory.

- `temp.dir` \[path\]::

  Temporary directory. Used if `file.dir` is `NA` to create temporary
  registries.

- `packages` \[character()\]::

  Packages to load on the slaves.

- `namespaces` \[character()\]::

  Namespaces to load on the slaves.

- `seed` \[integer(1)\]::

  Registry seed. Before each job is executed, the seed `seed + job.id`
  is set.

- `cluster.functions` \[cluster.functions\]::

  Usually set in your `conf.file`. Set via a call to
  [`makeClusterFunctions`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md).
  See example.

- `default.resources` \[named list()\]::

  Usually set in your `conf.file`. Named list of default resources.

- `max.concurrent.jobs` \[integer(1)\]::

  Usually set in your `conf.file`. Maximum number of concurrent jobs for
  a single user and current registry on the system.
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md)
  will try to respect this setting. The resource “max.concurrent.jobs”
  has higher precedence.

- `defs` \[data.table\]::

  Table with job definitions (i.e. parameters).

- `status` \[data.table\]::

  Table holding information about the computational status. Also see
  [`getJobStatus`](https://batchtools.mlr-org.com/reference/getJobTable.md).

- `resources` \[data.table\]::

  Table holding information about the computational resources used for
  the job. Also see
  [`getJobResources`](https://batchtools.mlr-org.com/reference/getJobTable.md).

- `tags` \[data.table\]::

  Table holding information about tags. See
  [Tags](https://batchtools.mlr-org.com/reference/Tags.md).

- `hash` \[character(1)\]::

  Unique hash which changes each time the registry gets saved to the
  file system. Can be utilized to invalidate the cache of knitr.

## Details

Currently batchtools understands the following options set via the
configuration file:

- `cluster.functions`::

  As returned by a constructor, e.g.
  [`makeClusterFunctionsSlurm`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md).

- `default.resources`::

  List of resources to use. Will be overruled by resources specified via
  [`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).

- `temp.dir`::

  Path to directory to use for temporary registries.

- `sleep`::

  Custom sleep function. See
  [`waitForJobs`](https://batchtools.mlr-org.com/reference/waitForJobs.md).

- `expire.after`::

  Number of iterations before treating jobs as expired in
  [`waitForJobs`](https://batchtools.mlr-org.com/reference/waitForJobs.md).

- `compress`::

  Compression algorithm to use via
  [`saveRDS`](https://rdrr.io/r/base/readRDS.html).

## See also

Other Registry:
[`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md),
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md),
[`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md),
[`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md),
[`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md),
[`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
print(tmp)
#> Job Registry
#>   Backend  : Interactive
#>   File dir : /tmp/batchtools-example/reg
#>   Work dir : /home/runner/work/batchtools/batchtools/docs/reference
#>   Jobs     : 0
#>   Seed     : 32563
#>   Writeable: TRUE

# Set cluster functions to interactive mode and start jobs in external R sessions
tmp$cluster.functions = makeClusterFunctionsInteractive(external = TRUE)

# Change packages to load
tmp$packages = c("MASS")
saveRegistry(reg = tmp)
#> [1] TRUE
```

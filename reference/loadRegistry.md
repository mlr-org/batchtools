# Load a Registry from the File System

Loads a registry from its `file.dir`.

Multiple R sessions accessing the same registry simultaneously can lead
to database inconsistencies. This is especially dangerous if the same
`file.dir` is accessed from multiple machines, e.g. via a mount.

If you just need to check on the status or peek into some preliminary
results while another process is still submitting or waiting for pending
results, you can load the registry in a read-only mode. All operations
that need to change the registry will raise an exception in this mode.
Files communicated back by the computational nodes are parsed to update
the registry in memory while the registry on the file system remains
unchanged.

A heuristic tries to detect if the registry has been altered in the
background by an other process and in this case automatically restricts
the current registry to read-only mode. However, you should rely on this
heuristic to work flawlessly. Thus, set to `writeable` to `TRUE` if and
only if you are absolutely sure that other state-changing processes are
terminated.

If you need write access, load the registry with `writeable` set to
`TRUE`.

## Usage

``` r
loadRegistry(
  file.dir,
  work.dir = NULL,
  conf.file = findConfFile(),
  make.default = TRUE,
  writeable = FALSE
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

- make.default:

  \[`logical(1)`\]  
  If set to `TRUE`, the created registry is saved inside the package
  namespace and acts as default registry. You might want to switch this
  off if you work with multiple registries simultaneously. Default is
  `TRUE`.

- writeable:

  \[`logical(1)`\]  
  Loads the registry in read-write mode. Default is `FALSE`.

## Value

\[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\].

## See also

Other Registry:
[`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md),
[`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md),
[`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md),
[`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md),
[`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md),
[`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md),
[`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)

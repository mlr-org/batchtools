# JobCollection Constructor

`makeJobCollection` takes multiple job ids and creates an object of
class “JobCollection” which holds all necessary information for the
calculation with
[`doJobCollection`](https://batchtools.mlr-org.com/reference/doJobCollection.md).
It is implemented as an environment with the following variables:

- file.dir:

  `file.dir` of the
  [Registry](https://batchtools.mlr-org.com/reference/makeRegistry.md).

- work.dir::

  `work.dir` of the
  [Registry](https://batchtools.mlr-org.com/reference/makeRegistry.md).

- job.hash:

  Unique identifier of the job. Used to create names on the file system.

- jobs:

  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  holding individual job information. See examples.

- log.file:

  Location of the designated log file for this job.

- resources::

  Named list of of specified computational resources.

- uri:

  Location of the job description file (saved with `link[base]{saveRDS}`
  on the file system.

- seed:

  `integer(1)` Seed of the
  [Registry](https://batchtools.mlr-org.com/reference/makeRegistry.md).

- packages:

  `character` with required packages to load via
  [`require`](https://rdrr.io/r/base/library.html).

- namespaces:

  `character` with required packages to load via
  [`requireNamespace`](https://rdrr.io/r/base/ns-load.html).

- source:

  `character` with list of files to source before execution.

- load:

  `character` with list of files to load before execution.

- array.var:

  `character(1)` of the array environment variable specified by the
  cluster functions.

- array.jobs:

  `logical(1)` signaling if jobs were submitted using
  `chunks.as.arrayjobs`.

If your
[ClusterFunctions](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)
uses a template, [`brew`](https://rdrr.io/pkg/brew/man/brew.html) will
be executed in the environment of such a collection. Thus all variables
available inside the job can be used in the template.

## Usage

``` r
makeJobCollection(ids = NULL, resources = list(), reg = getDefaultRegistry())
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

- resources:

  \[`list`\]  
  Named list of resources. Default is
  [`list()`](https://rdrr.io/r/base/list.html).

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[`JobCollection`\].

## See also

Other JobCollection:
[`doJobCollection()`](https://batchtools.mlr-org.com/reference/doJobCollection.md)

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE, packages = "methods")
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(identity, 1:5, reg = tmp)
#> Adding 5 jobs ...

# resources are usually set in submitJobs()
jc = makeJobCollection(1:3, resources = list(foo = "bar"), reg = tmp)
ls(jc)
#>  [1] "array.jobs" "array.var"  "compress"   "file.dir"   "job.hash"  
#>  [6] "job.name"   "jobs"       "load"       "log.file"   "namespaces"
#> [11] "packages"   "resources"  "seed"       "source"     "uri"       
#> [16] "work.dir"  
jc$resources
#> $foo
#> [1] "bar"
#> 
```

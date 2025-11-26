# Set and Retrieve Job Names

Set custom names for jobs. These are passed to the template as
‘job.name’. If no custom name is set (or any of the job names of the
chunk is missing), the job hash is used as job name. Individual job
names can be accessed via `jobs$job.name`.

## Usage

``` r
setJobNames(ids = NULL, names, reg = getDefaultRegistry())

getJobNames(ids = NULL, reg = getDefaultRegistry())
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

- names:

  \[`character`\]  
  Character vector of the same length as provided ids.

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

`setJobNames` returns `NULL` invisibly, `getJobTable` returns a
`data.table` with columns `job.id` and `job.name`.

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
ids = batchMap(identity, 1:10, reg = tmp)
#> Adding 10 jobs ...
setJobNames(ids, letters[1:nrow(ids)], reg = tmp)
getJobNames(reg = tmp)
#> Key: <job.id>
#>     job.id job.name
#>      <int>   <char>
#>  1:      1        a
#>  2:      2        b
#>  3:      3        c
#>  4:      4        d
#>  5:      5        e
#>  6:      6        f
#>  7:      7        g
#>  8:      8        h
#>  9:      9        i
#> 10:     10        j
```

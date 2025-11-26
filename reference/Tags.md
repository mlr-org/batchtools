# Add or Remove Job Tags

Add and remove arbitrary tags to jobs.

## Usage

``` r
addJobTags(ids = NULL, tags, reg = getDefaultRegistry())

removeJobTags(ids = NULL, tags, reg = getDefaultRegistry())

getUsedJobTags(ids = NULL, reg = getDefaultRegistry())
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

- tags:

  \[`character`\]  
  Tags to add or remove as strings. Each tag may consist of letters,
  numbers, underscore and dots (pattern “^\[\[:alnum:\]\_.\]+”).

- reg:

  \[[`Registry`](https://batchtools.mlr-org.com/reference/makeRegistry.md)\]  
  Registry. If not explicitly passed, uses the default registry (see
  [`setDefaultRegistry`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)).

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with job ids affected (invisible).

## Examples

``` r
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
ids = batchMap(sqrt, x = -3:3, reg = tmp)
#> Adding 7 jobs ...

# Add new tag to all ids
addJobTags(ids, "needs.computation", reg = tmp)
getJobTags(reg = tmp)
#> Key: <job.id>
#>    job.id              tags
#>     <int>            <char>
#> 1:      1 needs.computation
#> 2:      2 needs.computation
#> 3:      3 needs.computation
#> 4:      4 needs.computation
#> 5:      5 needs.computation
#> 6:      6 needs.computation
#> 7:      7 needs.computation

# Add more tags
addJobTags(findJobs(x < 0, reg = tmp), "x.neg", reg = tmp)
addJobTags(findJobs(x > 0, reg = tmp), "x.pos", reg = tmp)
getJobTags(reg = tmp)
#> Key: <job.id>
#>    job.id                    tags
#>     <int>                  <char>
#> 1:      1 needs.computation,x.neg
#> 2:      2 needs.computation,x.neg
#> 3:      3 needs.computation,x.neg
#> 4:      4       needs.computation
#> 5:      5 needs.computation,x.pos
#> 6:      6 needs.computation,x.pos
#> 7:      7 needs.computation,x.pos

# Submit first 5 jobs and remove tag if successful
ids = submitJobs(1:5, reg = tmp)
#> Submitting 5 jobs in 5 chunks using cluster functions 'Interactive' ...
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced
if (waitForJobs(reg = tmp))
  removeJobTags(ids, "needs.computation", reg = tmp)
getJobTags(reg = tmp)
#> Key: <job.id>
#>    job.id                    tags
#>     <int>                  <char>
#> 1:      1                   x.neg
#> 2:      2                   x.neg
#> 3:      3                   x.neg
#> 4:      4                    <NA>
#> 5:      5                   x.pos
#> 6:      6 needs.computation,x.pos
#> 7:      7 needs.computation,x.pos

# Grep for warning message and add a tag
addJobTags(grepLogs(pattern = "NaNs produced", reg = tmp), "div.zero", reg = tmp)
getJobTags(reg = tmp)
#> Key: <job.id>
#>    job.id                    tags
#>     <int>                  <char>
#> 1:      1                   x.neg
#> 2:      2                   x.neg
#> 3:      3                   x.neg
#> 4:      4                    <NA>
#> 5:      5                   x.pos
#> 6:      6 needs.computation,x.pos
#> 7:      7 needs.computation,x.pos

# All tags where tag x.neg is set:
ids = findTagged("x.neg", reg = tmp)
getUsedJobTags(ids, reg = tmp)
#> [1] "x.neg"
```

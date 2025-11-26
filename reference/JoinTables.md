# Inner, Left, Right, Outer, Semi and Anti Join for Data Tables

These helper functions perform join operations on data tables. Most of
them are basically one-liners. See
<https://rpubs.com/ronasta/join_data_tables> for a overview of join
operations in data table or alternatively dplyr's vignette on two table
verbs.

## Usage

``` r
ijoin(x, y, by = NULL)

ljoin(x, y, by = NULL)

rjoin(x, y, by = NULL)

ojoin(x, y, by = NULL)

sjoin(x, y, by = NULL)

ajoin(x, y, by = NULL)

ujoin(x, y, all.y = FALSE, by = NULL)
```

## Arguments

- x:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html)\]  
  First data.frame to join.

- y:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html)\]  
  Second data.frame to join.

- by:

  \[`character`\]  
  Column name(s) of variables used to match rows in `x` and `y`. If not
  provided, a heuristic similar to the one described in the dplyr
  vignette is used:

  1.  If `x` is keyed, the existing key will be used if `y` has the same
      column(s).

  2.  If `x` is not keyed, the intersect of common columns names is used
      if not empty.

  3.  Raise an exception.

  You may pass a named character vector to merge on columns with
  different names in `x` and `y`: `by = c("x.id" = "y.id")` will match
  `x`'s “x.id” column with `y`\\s “y.id” column.

- all.y:

  \[logical(1)\]  
  Keep columns of `y` which are not in `x`?

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]
with key identical to `by`.

## Examples

``` r
# Create two tables for demonstration
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg' using cluster functions 'Interactive'
batchMap(identity, x = 1:6, reg = tmp)
#> Adding 6 jobs ...
x = getJobPars(reg = tmp)
y = findJobs(x >= 2 & x <= 5, reg = tmp)
y$extra.col = head(letters, nrow(y))

# Inner join: similar to intersect(): keep all columns of x and y with common matches
ijoin(x, y)
#> Key: <job.id>
#>    job.id  job.pars extra.col
#>     <int>    <list>    <char>
#> 1:      2 <list[1]>         a
#> 2:      3 <list[1]>         b
#> 3:      4 <list[1]>         c
#> 4:      5 <list[1]>         d

# Left join: use all ids from x, keep all columns of x and y
ljoin(x, y)
#> Key: <job.id>
#>    job.id extra.col  job.pars
#>     <int>    <char>    <list>
#> 1:      1      <NA> <list[1]>
#> 2:      2         a <list[1]>
#> 3:      3         b <list[1]>
#> 4:      4         c <list[1]>
#> 5:      5         d <list[1]>
#> 6:      6      <NA> <list[1]>

# Right join: use all ids from y, keep all columns of x and y
rjoin(x, y)
#> Key: <job.id>
#>    job.id  job.pars extra.col
#>     <int>    <list>    <char>
#> 1:      2 <list[1]>         a
#> 2:      3 <list[1]>         b
#> 3:      4 <list[1]>         c
#> 4:      5 <list[1]>         d

# Outer join: similar to union(): keep all columns of x and y with matches in x or y
ojoin(x, y)
#> Key: <job.id>
#>    job.id  job.pars extra.col
#>     <int>    <list>    <char>
#> 1:      1 <list[1]>      <NA>
#> 2:      2 <list[1]>         a
#> 3:      3 <list[1]>         b
#> 4:      4 <list[1]>         c
#> 5:      5 <list[1]>         d
#> 6:      6 <list[1]>      <NA>

# Semi join: filter x with matches in y
sjoin(x, y)
#> Key: <job.id>
#>    job.id  job.pars
#>     <int>    <list>
#> 1:      2 <list[1]>
#> 2:      3 <list[1]>
#> 3:      4 <list[1]>
#> 4:      5 <list[1]>

# Anti join: filter x with matches not in y
ajoin(x, y)
#> Key: <job.id>
#>    job.id  job.pars
#>     <int>    <list>
#> 1:      1 <list[1]>
#> 2:      6 <list[1]>

# Updating join: Replace values in x with values in y
ujoin(x, y)
#> Key: <job.id>
#>    job.id  job.pars
#>     <int>    <list>
#> 1:      1 <list[1]>
#> 2:      2 <list[1]>
#> 3:      3 <list[1]>
#> 4:      4 <list[1]>
#> 5:      5 <list[1]>
#> 6:      6 <list[1]>
```

# Unwrap Nested Data Frames

Some functions (e.g.,
[`getJobPars`](https://batchtools.mlr-org.com/reference/getJobTable.md),
[`getJobResources`](https://batchtools.mlr-org.com/reference/getJobTable.md)
or
[`reduceResultsDataTable`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
return a `data.table` with columns of type `list`. These columns can be
unnested/unwrapped with this function. The contents of these columns
will be transformed to a `data.table` and
[`cbind`](https://rdrr.io/r/base/cbind.html)-ed to the input data.frame
`x`, replacing the original nested column.

## Usage

``` r
unwrap(x, cols = NULL, sep = NULL)

flatten(x, cols = NULL, sep = NULL)
```

## Arguments

- x:

  \[[`data.frame`](https://rdrr.io/r/base/data.frame.html) \|
  [`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\]  
  Data frame to flatten.

- cols:

  \[`character`\]  
  Columns to consider for this operation. If set to `NULL` (default),
  will operate on all columns of type “list”.

- sep:

  \[`character(1)`\]  
  If `NULL` (default), the column names of the additional columns will
  re-use the names of the nested `list`/`data.frame`. This may lead to
  name clashes. If you provide `sep`, the variable column name will be
  constructed as “\[column name of x\]\[sep\]\[inner name\]”.

## Value

\[[`data.table`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)\].

## Note

There is a name clash with function `flatten` in package purrr. The
function `flatten` is discouraged to use for this reason in favor of
`unwrap`.

## Examples

``` r
x = data.table::data.table(
  id = 1:3,
  values = list(list(a = 1, b = 3), list(a = 2, b = 2), list(a = 3))
)
unwrap(x)
#>       id     a     b
#>    <int> <num> <num>
#> 1:     1     1     3
#> 2:     2     2     2
#> 3:     3     3    NA
unwrap(x, sep = ".")
#>       id values.a values.b
#>    <int>    <num>    <num>
#> 1:     1        1        3
#> 2:     2        2        2
#> 3:     3        3       NA
```

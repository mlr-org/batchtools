# Chunk Jobs for Sequential Execution

Jobs can be partitioned into “chunks” to be executed sequentially on the
computational nodes. Chunks are defined by providing a data frame with
columns “job.id” and “chunk” (integer) to
[`submitJobs`](https://batchtools.mlr-org.com/reference/submitJobs.md).
All jobs with the same chunk number will be grouped together on one node
to form a single computational job.

The function `chunk` simply splits `x` into either a fixed number of
groups, or into a variable number of groups with a fixed number of
maximum elements.

The function `lpt` also groups `x` into a fixed number of chunks, but
uses the actual values of `x` in a greedy “Longest Processing Time”
algorithm. As a result, the maximum sum of elements in minimized.

`binpack` splits `x` into a variable number of groups whose sum of
elements do not exceed the upper limit provided by `chunk.size`.

See examples of
[`estimateRuntimes`](https://batchtools.mlr-org.com/reference/estimateRuntimes.md)
for an application of `binpack` and `lpt`.

## Usage

``` r
chunk(x, n.chunks = NULL, chunk.size = NULL, shuffle = TRUE)

lpt(x, n.chunks = 1L)

binpack(x, chunk.size = max(x))
```

## Arguments

- x:

  \[`numeric`\]  
  For `chunk` an atomic vector (usually the `job.id`). For `binpack` and
  `lpt`, the weights to group.

- n.chunks:

  \[`integer(1)`\]  
  Requested number of chunks. The function `chunk` distributes the
  number of elements in `x` evenly while `lpt` tries to even out the sum
  of elements in each chunk. If more chunks than necessary are
  requested, empty chunks are ignored. Mutually exclusive with
  `chunks.size`.

- chunk.size:

  \[`integer(1)`\]  
  Requested chunk size for each single chunk. For `chunk` this is the
  number of elements in `x`, for `binpack` the size is determined by the
  sum of values in `x`. Mutually exclusive with `n.chunks`.

- shuffle:

  \[`logical(1)`\]  
  Shuffles the groups. Default is `TRUE`.

## Value

\[`integer`\] giving the chunk number for each element of `x`.

## See also

[`estimateRuntimes`](https://batchtools.mlr-org.com/reference/estimateRuntimes.md)

## Examples

``` r
ch = chunk(1:10, n.chunks = 2)
table(ch)
#> ch
#> 1 2 
#> 5 5 

ch = chunk(rep(1, 10), chunk.size = 2)
table(ch)
#> ch
#> 1 2 3 4 5 
#> 2 2 2 2 2 

set.seed(1)
x = runif(10)
ch = lpt(x, n.chunks = 2)
sapply(split(x, ch), sum)
#>        1        2 
#> 2.808393 2.706746 

set.seed(1)
x = runif(10)
ch = binpack(x, 1)
sapply(split(x, ch), sum)
#>         1         2         3         4         5         6 
#> 0.9446753 0.9699941 0.8983897 0.9263065 0.8307960 0.9449773 

# Job chunking
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg1' using cluster functions 'Interactive'
ids = batchMap(identity, 1:25, reg = tmp)
#> Adding 25 jobs ...

### Group into chunks with 10 jobs each
library(data.table)
ids[, chunk := chunk(job.id, chunk.size = 10)]
#> Key: <job.id>
#>     job.id chunk
#>      <int> <int>
#>  1:      1     3
#>  2:      2     1
#>  3:      3     1
#>  4:      4     2
#>  5:      5     3
#>  6:      6     1
#>  7:      7     3
#>  8:      8     3
#>  9:      9     2
#> 10:     10     1
#> 11:     11     1
#> 12:     12     2
#> 13:     13     2
#> 14:     14     1
#> 15:     15     2
#> 16:     16     1
#> 17:     17     3
#> 18:     18     1
#> 19:     19     2
#> 20:     20     1
#> 21:     21     2
#> 22:     22     3
#> 23:     23     2
#> 24:     24     3
#> 25:     25     3
#>     job.id chunk
print(ids[, .N, by = chunk])
#>    chunk     N
#>    <int> <int>
#> 1:     3     8
#> 2:     1     9
#> 3:     2     8

### Group into 4 chunks
ids[, chunk := chunk(job.id, n.chunks = 4)]
#> Key: <job.id>
#>     job.id chunk
#>      <int> <int>
#>  1:      1     2
#>  2:      2     3
#>  3:      3     4
#>  4:      4     3
#>  5:      5     4
#>  6:      6     1
#>  7:      7     4
#>  8:      8     1
#>  9:      9     2
#> 10:     10     2
#> 11:     11     3
#> 12:     12     3
#> 13:     13     4
#> 14:     14     1
#> 15:     15     3
#> 16:     16     2
#> 17:     17     1
#> 18:     18     2
#> 19:     19     3
#> 20:     20     4
#> 21:     21     1
#> 22:     22     2
#> 23:     23     4
#> 24:     24     1
#> 25:     25     1
#>     job.id chunk
print(ids[, .N, by = chunk])
#>    chunk     N
#>    <int> <int>
#> 1:     2     6
#> 2:     3     6
#> 3:     4     6
#> 4:     1     7

### Submit to batch system
submitJobs(ids = ids, reg = tmp)
#> Submitting 25 jobs in 4 chunks using cluster functions 'Interactive' ...

# Grouped chunking
tmp = makeExperimentRegistry(file.dir = NA, make.default = FALSE)
#> No readable configuration file found
#> Created registry in '/tmp/batchtools-example/reg2' using cluster functions 'Interactive'
prob = addProblem(reg = tmp, "prob1", data = iris, fun = function(job, data) nrow(data))
#> Adding problem 'prob1'
prob = addProblem(reg = tmp, "prob2", data = Titanic, fun = function(job, data) nrow(data))
#> Adding problem 'prob2'
algo = addAlgorithm(reg = tmp, "algo", fun = function(job, data, instance, i, ...) problem)
#> Adding algorithm 'algo'
prob.designs = list(prob1 = data.table(), prob2 = data.table(x = 1:2))
algo.designs = list(algo = data.table(i = 1:3))
addExperiments(prob.designs, algo.designs, repls = 3, reg = tmp)
#> Adding 9 experiments ('prob1'[1] x 'algo'[3] x repls[3]) ...
#> Adding 18 experiments ('prob2'[2] x 'algo'[3] x repls[3]) ...

### Group into chunks of 5 jobs, but do not put multiple problems into the same chunk
# -> only one problem has to be loaded per chunk, and only once because it is cached
ids = getJobTable(reg = tmp)[, .(job.id, problem, algorithm)]
ids[, chunk := chunk(job.id, chunk.size = 5), by = "problem"]
#> Key: <job.id>
#>     job.id problem algorithm chunk
#>      <int>  <char>    <char> <int>
#>  1:      1   prob1      algo     1
#>  2:      2   prob1      algo     1
#>  3:      3   prob1      algo     2
#>  4:      4   prob1      algo     2
#>  5:      5   prob1      algo     1
#>  6:      6   prob1      algo     2
#>  7:      7   prob1      algo     1
#>  8:      8   prob1      algo     1
#>  9:      9   prob1      algo     2
#> 10:     10   prob2      algo     2
#> 11:     11   prob2      algo     1
#> 12:     12   prob2      algo     1
#> 13:     13   prob2      algo     3
#> 14:     14   prob2      algo     3
#> 15:     15   prob2      algo     3
#> 16:     16   prob2      algo     2
#> 17:     17   prob2      algo     2
#> 18:     18   prob2      algo     2
#> 19:     19   prob2      algo     2
#> 20:     20   prob2      algo     4
#> 21:     21   prob2      algo     1
#> 22:     22   prob2      algo     1
#> 23:     23   prob2      algo     3
#> 24:     24   prob2      algo     4
#> 25:     25   prob2      algo     1
#> 26:     26   prob2      algo     4
#> 27:     27   prob2      algo     4
#>     job.id problem algorithm chunk
ids[, chunk := .GRP, by = c("problem", "chunk")]
#> Key: <job.id>
#>     job.id problem algorithm chunk
#>      <int>  <char>    <char> <int>
#>  1:      1   prob1      algo     1
#>  2:      2   prob1      algo     1
#>  3:      3   prob1      algo     2
#>  4:      4   prob1      algo     2
#>  5:      5   prob1      algo     1
#>  6:      6   prob1      algo     2
#>  7:      7   prob1      algo     1
#>  8:      8   prob1      algo     1
#>  9:      9   prob1      algo     2
#> 10:     10   prob2      algo     3
#> 11:     11   prob2      algo     4
#> 12:     12   prob2      algo     4
#> 13:     13   prob2      algo     5
#> 14:     14   prob2      algo     5
#> 15:     15   prob2      algo     5
#> 16:     16   prob2      algo     3
#> 17:     17   prob2      algo     3
#> 18:     18   prob2      algo     3
#> 19:     19   prob2      algo     3
#> 20:     20   prob2      algo     6
#> 21:     21   prob2      algo     4
#> 22:     22   prob2      algo     4
#> 23:     23   prob2      algo     5
#> 24:     24   prob2      algo     6
#> 25:     25   prob2      algo     4
#> 26:     26   prob2      algo     6
#> 27:     27   prob2      algo     6
#>     job.id problem algorithm chunk
dcast(ids, chunk ~ problem)
#> Using 'chunk' as value column. Use 'value.var' to override
#> Warning: 'fun.aggregate' is NULL, but found duplicate row/column combinations, so defaulting to length(). That is, the variables [chunk, problem] used in 'formula' do not uniquely identify rows in the input 'data'. In such cases, 'fun.aggregate' is used to derive a single representative value for each combination in the output data.table, for example by summing or averaging (fun.aggregate=sum or fun.aggregate=mean, respectively). Check the resulting table for values larger than 1 to see which combinations were not unique. See ?dcast.data.table for more details.
#> Key: <chunk>
#>    chunk prob1 prob2
#>    <int> <int> <int>
#> 1:     1     5     0
#> 2:     2     4     0
#> 3:     3     0     5
#> 4:     4     0     5
#> 5:     5     0     4
#> 6:     6     0     4
```

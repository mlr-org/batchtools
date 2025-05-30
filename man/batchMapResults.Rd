% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/batchMapResults.R
\name{batchMapResults}
\alias{batchMapResults}
\title{Map Over Results to Create New Jobs}
\usage{
batchMapResults(
  fun,
  ids = NULL,
  ...,
  more.args = list(),
  target,
  source = getDefaultRegistry()
)
}
\arguments{
\item{fun}{[\code{function}]\cr
Function which takes the result as first (unnamed) argument.}

\item{ids}{[\code{\link[base]{data.frame}} or \code{integer}]\cr
A \code{\link[base]{data.frame}} (or \code{\link[data.table]{data.table}})
with a column named \dQuote{job.id}.
Alternatively, you may also pass a vector of integerish job ids.
If not set, defaults to the return value of \code{\link{findDone}}.
Invalid ids are ignored.}

\item{...}{[ANY]\cr
Arguments to vectorize over (list or vector). Passed to \code{\link{batchMap}}.}

\item{more.args}{[\code{list}]\cr
A list of further arguments passed to \code{fun}.
Default is an empty list.}

\item{target}{[\code{\link{Registry}}]\cr
Empty Registry where new jobs are created for.}

\item{source}{[\code{\link{Registry}}]\cr
Registry. If not explicitly passed, uses the default registry (see \code{\link{setDefaultRegistry}}).}
}
\value{
[\code{\link{data.table}}] with ids of jobs added to \code{target}.
}
\description{
This function allows you to create new computational jobs (just like \code{\link{batchMap}} based on the results of
a \code{\link{Registry}}.
}
\note{
The URI to the result files in registry \code{source} is hard coded as parameter in the \code{target} registry.
This means that \code{target} is currently not portable between systems for computation.
}
\examples{
\dontshow{ batchtools:::example_push_temp(2) }
# Source registry: calculate square of some numbers
tmp = makeRegistry(file.dir = NA, make.default = FALSE)
batchMap(function(x) list(square = x^2), x = 1:10, reg = tmp)
submitJobs(reg = tmp)
waitForJobs(reg = tmp)

# Target registry: calculate the square root on results of first registry
target = makeRegistry(file.dir = NA, make.default = FALSE)
batchMapResults(fun = function(x, y) list(sqrt = sqrt(x$square)), ids = 4:8,
  target = target, source = tmp)
submitJobs(reg = target)
waitForJobs(reg = target)

# Map old to new ids. First, get a table with results and parameters
results = unwrap(rjoin(getJobPars(reg = target), reduceResultsDataTable(reg = target)))
print(results)

# Parameter '.id' points to job.id in 'source'. Use a inner join to combine:
ijoin(results, unwrap(reduceResultsDataTable(reg = tmp)), by = c(".id" = "job.id"))
}
\seealso{
Other Results: 
\code{\link{loadResult}()},
\code{\link{reduceResults}()},
\code{\link{reduceResultsList}()}
}
\concept{Results}

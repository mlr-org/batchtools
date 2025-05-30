% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clusterFunctionsDocker.R
\name{makeClusterFunctionsDocker}
\alias{makeClusterFunctionsDocker}
\title{ClusterFunctions for Docker}
\usage{
makeClusterFunctionsDocker(
  image,
  docker.args = character(0L),
  image.args = character(0L),
  scheduler.latency = 1,
  fs.latency = 65
)
}
\arguments{
\item{image}{[\code{character(1)}]\cr
Name of the docker image to run.}

\item{docker.args}{[\code{character}]\cr
Additional arguments passed to \dQuote{docker} *before* the command (\dQuote{run}, \dQuote{ps} or \dQuote{kill}) to execute (e.g., the docker host).}

\item{image.args}{[\code{character}]\cr
Additional arguments passed to \dQuote{docker run} (e.g., to define mounts or environment variables).}

\item{scheduler.latency}{[\code{numeric(1)}]\cr
Time to sleep after important interactions with the scheduler to ensure a sane state.
Currently only triggered after calling \code{\link{submitJobs}}.}

\item{fs.latency}{[\code{numeric(1)}]\cr
Expected maximum latency of the file system, in seconds.
Set to a positive number for network file systems like NFS which enables more robust (but also more expensive) mechanisms to
access files and directories.
Usually safe to set to \code{0} to disable the heuristic, e.g. if you are working on a local file system.}
}
\value{
[\code{\link{ClusterFunctions}}].
}
\description{
Cluster functions for Docker/Docker Swarm (\url{https://docs.docker.com/engine/swarm/}).

The \code{submitJob} function executes
\code{docker [docker.args] run --detach=true [image.args] [resources] [image] [cmd]}.
Arguments \code{docker.args}, \code{image.args} and \code{image} can be set on construction.
The \code{resources} part takes the named resources \code{ncpus} and \code{memory}
from \code{\link{submitJobs}} and maps them to the arguments \code{--cpu-shares} and \code{--memory}
(in Megabytes). The resource \code{threads} is mapped to the environment variables \dQuote{OMP_NUM_THREADS}
and \dQuote{OPENBLAS_NUM_THREADS}.
To reliably identify jobs in the swarm, jobs are labeled with \dQuote{batchtools=[job.hash]} and named
using the current login name (label \dQuote{user}) and the job hash (label \dQuote{batchtools}).

\code{listJobsRunning} uses \code{docker [docker.args] ps --format=\{\{.ID\}\}} to filter for running jobs.

\code{killJobs} uses \code{docker [docker.args] kill [batch.id]} to filter for running jobs.

These cluster functions use a \link{Hook} to remove finished jobs before a new submit and every time the \link{Registry}
is synchronized (using \code{\link{syncRegistry}}).
This is currently required because docker does not remove terminated containers automatically.
Use \code{docker ps -a --filter 'label=batchtools' --filter 'status=exited'} to identify and remove terminated
containers manually (or usa a cron job).
}
\seealso{
Other ClusterFunctions: 
\code{\link{makeClusterFunctions}()},
\code{\link{makeClusterFunctionsInteractive}()},
\code{\link{makeClusterFunctionsLSF}()},
\code{\link{makeClusterFunctionsMulticore}()},
\code{\link{makeClusterFunctionsOpenLava}()},
\code{\link{makeClusterFunctionsSGE}()},
\code{\link{makeClusterFunctionsSSH}()},
\code{\link{makeClusterFunctionsSlurm}()},
\code{\link{makeClusterFunctionsSocket}()},
\code{\link{makeClusterFunctionsTORQUE}()}
}
\concept{ClusterFunctions}

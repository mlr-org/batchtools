% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clusterFunctionsSlurm.R
\name{makeClusterFunctionsSlurm}
\alias{makeClusterFunctionsSlurm}
\title{ClusterFunctions for Slurm Systems}
\usage{
makeClusterFunctionsSlurm(
  template = "slurm",
  array.jobs = TRUE,
  nodename = "localhost",
  scheduler.latency = 1,
  fs.latency = 65
)
}
\arguments{
\item{template}{[\code{character(1)}]\cr
Either a path to a \pkg{brew} template file (with extension \dQuote{tmpl}), or a short descriptive name enabling the following heuristic for the file lookup:
\enumerate{
  \item \dQuote{batchtools.[template].tmpl} in the path specified by the environment variable \dQuote{R_BATCHTOOLS_SEARCH_PATH}.
  \item \dQuote{batchtools.[template].tmpl} in the current working directory.
  \item \dQuote{[template].tmpl} in the user config directory (see \code{\link[rappdirs]{user_config_dir}}); on linux this is usually \dQuote{~/.config/batchtools/[template].tmpl}.
  \item \dQuote{.batchtools.[template].tmpl} in the home directory.
  \item \dQuote{[template].tmpl} in the package installation directory in the subfolder \dQuote{templates}.
}}

\item{array.jobs}{[\code{logical(1)}]\cr
If array jobs are disabled on the computing site, set to \code{FALSE}.}

\item{nodename}{[\code{character(1)}]\cr
Nodename of the master host. All commands are send via SSH to this host. Only works iff
\enumerate{
  \item{Passwordless authentication (e.g., via SSH public key authentication) is set up.}
  \item{The file directory is shared across machines, e.g. mounted via SSHFS.}
  \item{Either the absolute path to the \code{file.dir} is identical on the machines, or paths are provided relative to the home directory. Symbolic links should work.}
}}

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
Cluster functions for Slurm (\url{https://slurm.schedmd.com/}).

Job files are created based on the brew template \code{template.file}. This
file is processed with brew and then submitted to the queue using the
\code{sbatch} command. Jobs are killed using the \code{scancel} command and
the list of running jobs is retrieved using \code{squeue}. The user must
have the appropriate privileges to submit, delete and list jobs on the
cluster (this is usually the case).

The template file can access all resources passed to \code{\link{submitJobs}}
as well as all variables stored in the \code{\link{JobCollection}}.
It is the template file's job to choose a queue for the job and handle the desired resource
allocations.

Note that you might have to specify the cluster name here if you do not want to use the default,
otherwise the commands for listing and killing jobs will not work.
}
\seealso{
Other ClusterFunctions: 
\code{\link{makeClusterFunctions}()},
\code{\link{makeClusterFunctionsDocker}()},
\code{\link{makeClusterFunctionsInteractive}()},
\code{\link{makeClusterFunctionsLSF}()},
\code{\link{makeClusterFunctionsMulticore}()},
\code{\link{makeClusterFunctionsOpenLava}()},
\code{\link{makeClusterFunctionsSGE}()},
\code{\link{makeClusterFunctionsSSH}()},
\code{\link{makeClusterFunctionsSocket}()},
\code{\link{makeClusterFunctionsTORQUE}()}
}
\concept{ClusterFunctions}

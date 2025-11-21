#' @title ClusterFunctions for HyperQueue
#'
#' @description
#' Cluster functions for HyperQueue (\url{https://it4innovations.github.io/hyperqueue/stable/}).
#'
#' Jobs are submitted via the HyperQueue CLI using \code{hq submit} and executed by  calling \code{Rscript -e "batchtools::doJobCollection(...)"}.
#' The job name is set to the job hash and logs are handled internally by batchtools.
#' Listing jobs uses \code{hq job list} and cancelling jobs uses \code{hq job cancel}.
#' A running HyperQueue server and workers are required.
#'
#'
#' @inheritParams makeClusterFunctions
#' @return [ClusterFunctions].
#' @family ClusterFunctions
#' @export
makeClusterFunctionsHyperQueue = function(scheduler.latency = 1, fs.latency = 65) {
  submitJob = function(reg, jc) {
    assertRegistry(reg, writeable = TRUE)
    assertClass(jc, "JobCollection")

    ncpus = if (!is.null(jc$resources$ncpus)) sprintf("--cpus=%i", jc$resources$ncpus)
    memory = if (!is.null(jc$resources$memory)) sprintf("--resource mem=%iMiB", jc$resources$memory)
    # time-limit is the maximum time the job can run, time-request is the minimum remaining lifetime a worker must have
    walltime =  if (!is.null(jc$resources$walltime)) sprintf("--time-limit=%is --time-request=%is", jc$resources$walltime, jc$resources$walltime)


    args = c(
      "submit",
      sprintf("--name=%s", jc$job.hash),
      # hyperqueue cannot write stdout and stderr to the same file
      "--stdout=none",
      "--stderr=none",
      ncpus,
      memory,
      walltime,
      "--",
      "Rscript", "-e",
      shQuote(sprintf("batchtools::doJobCollection('%s', '%s')", jc$uri, jc$log.file))
    )
    res = runOSCommand("hq", args)
    if (res$exit.code > 0L) {
      return(cfHandleUnknownSubmitError("hq", res$exit.code, res$output))
    }
    batch_ids = sub(".*job ID: ([0-9]+).*", "\\1", res$output)
    makeSubmitJobResult(status = 0L, batch.id = batch_ids)
  }

  killJob = function(reg, batch.id) {
    assertRegistry(reg, writeable = TRUE)
    assertString(batch.id)
    args = c("job", "cancel", batch.id)
    res = runOSCommand("hq", args)
    if (res$exit.code > 0L) {
      OSError("Killing of job failed", res)
    }
    makeSubmitJobResult(status = 0L, batch.id = batch.id)
  }


  listJobsQueued = function(reg) {
    requireNamespace("jsonlite")
    assertRegistry(reg, writeable = FALSE)
    args = c("job", "list", "--filter", "waiting", "--output-mode", "json")
    res = runOSCommand("hq", args)
    if (res$exit.code > 0L) {
      OSError("Listing of jobs failed", res)
    }
    jobs = jsonlite::fromJSON(res$output)
    as.character(jobs$id)
  }

  listJobsRunning = function(reg) {
    requireNamespace("jsonlite")
    assertRegistry(reg, writeable = FALSE)
    args = c("job", "list", "--filter", "running", "--output-mode", "json")
    res = runOSCommand("hq", args)
    if (res$exit.code > 0L) {
      OSError("Listing of jobs failed", res)
    }
    jobs = jsonlite::fromJSON(res$output)
    as.character(jobs$id)
  }

  makeClusterFunctions(
    name = "HyperQueue",
    submitJob = submitJob,
    killJob = killJob,
    listJobsRunning = listJobsRunning,
    listJobsQueued = listJobsQueued,
    store.job.collection = TRUE,
    scheduler.latency = scheduler.latency,
    fs.latency = fs.latency)
}

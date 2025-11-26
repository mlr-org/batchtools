# Package index

## Overview

- [`batchtools`](https://batchtools.mlr-org.com/reference/batchtools-package.md)
  [`batchtools-package`](https://batchtools.mlr-org.com/reference/batchtools-package.md)
  : batchtools: Tools for Computation on Batch Systems

## Registry

- [`makeRegistry()`](https://batchtools.mlr-org.com/reference/makeRegistry.md)
  : Registry Constructor
- [`makeExperimentRegistry()`](https://batchtools.mlr-org.com/reference/makeExperimentRegistry.md)
  : ExperimentRegistry Constructor
- [`assertRegistry()`](https://batchtools.mlr-org.com/reference/assertRegistry.md)
  : assertRegistry
- [`loadRegistry()`](https://batchtools.mlr-org.com/reference/loadRegistry.md)
  : Load a Registry from the File System
- [`saveRegistry()`](https://batchtools.mlr-org.com/reference/saveRegistry.md)
  : Store the Registy to the File System
- [`syncRegistry()`](https://batchtools.mlr-org.com/reference/syncRegistry.md)
  : Synchronize the Registry
- [`sweepRegistry()`](https://batchtools.mlr-org.com/reference/sweepRegistry.md)
  : Check Consistency and Remove Obsolete Information
- [`removeRegistry()`](https://batchtools.mlr-org.com/reference/removeRegistry.md)
  : Remove a Registry from the File System
- [`getDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)
  [`setDefaultRegistry()`](https://batchtools.mlr-org.com/reference/getDefaultRegistry.md)
  : Get and Set the Default Registry

## Define Jobs

- [`batchMap()`](https://batchtools.mlr-org.com/reference/batchMap.md) :
  Map Operation for Batch Systems
- [`batchReduce()`](https://batchtools.mlr-org.com/reference/batchReduce.md)
  : Reduce Operation for Batch Systems
- [`batchMapResults()`](https://batchtools.mlr-org.com/reference/batchMapResults.md)
  : Map Over Results to Create New Jobs
- [`addProblem()`](https://batchtools.mlr-org.com/reference/addProblem.md)
  [`removeProblems()`](https://batchtools.mlr-org.com/reference/addProblem.md)
  : Define Problems for Experiments
- [`addAlgorithm()`](https://batchtools.mlr-org.com/reference/addAlgorithm.md)
  [`removeAlgorithms()`](https://batchtools.mlr-org.com/reference/addAlgorithm.md)
  : Define Algorithms for Experiments
- [`addExperiments()`](https://batchtools.mlr-org.com/reference/addExperiments.md)
  : Add Experiments to the Registry

## Submit Jobs

- [`submitJobs()`](https://batchtools.mlr-org.com/reference/submitJobs.md)
  : Submit Jobs to the Batch Systems
- [`batchExport()`](https://batchtools.mlr-org.com/reference/batchExport.md)
  : Export Objects to the Slaves
- [`waitForJobs()`](https://batchtools.mlr-org.com/reference/waitForJobs.md)
  : Wait for Termination of Jobs
- [`chunk()`](https://batchtools.mlr-org.com/reference/chunk.md)
  [`lpt()`](https://batchtools.mlr-org.com/reference/chunk.md)
  [`binpack()`](https://batchtools.mlr-org.com/reference/chunk.md) :
  Chunk Jobs for Sequential Execution
- [`setJobNames()`](https://batchtools.mlr-org.com/reference/JobNames.md)
  [`getJobNames()`](https://batchtools.mlr-org.com/reference/JobNames.md)
  : Set and Retrieve Job Names

## Query Job Information

- [`getStatus()`](https://batchtools.mlr-org.com/reference/getStatus.md)
  : Summarize the Computational Status
- [`findJobs()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findExperiments()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findSubmitted()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findNotSubmitted()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findStarted()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findNotStarted()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findDone()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findNotDone()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findErrors()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findOnSystem()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findRunning()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findQueued()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findExpired()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  [`findTagged()`](https://batchtools.mlr-org.com/reference/findJobs.md)
  : Find and Filter Jobs
- [`getJobTable()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  [`getJobStatus()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  [`getJobResources()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  [`getJobPars()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  [`getJobTags()`](https://batchtools.mlr-org.com/reference/getJobTable.md)
  : Query Job Information
- [`summarizeExperiments()`](https://batchtools.mlr-org.com/reference/summarizeExperiments.md)
  : Quick Summary over Experiments

## Retrieve Results

- [`reduceResults()`](https://batchtools.mlr-org.com/reference/reduceResults.md)
  : Reduce Results
- [`reduceResultsList()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
  [`reduceResultsDataTable()`](https://batchtools.mlr-org.com/reference/reduceResultsList.md)
  : Apply Functions on Results
- [`loadResult()`](https://batchtools.mlr-org.com/reference/loadResult.md)
  : Load the Result of a Single Job
- [`unwrap()`](https://batchtools.mlr-org.com/reference/unwrap.md)
  [`flatten()`](https://batchtools.mlr-org.com/reference/unwrap.md) :
  Unwrap Nested Data Frames

## Debugging

- [`resetJobs()`](https://batchtools.mlr-org.com/reference/resetJobs.md)
  : Reset the Computational State of Jobs
- [`testJob()`](https://batchtools.mlr-org.com/reference/testJob.md) :
  Run Jobs Interactively
- [`showLog()`](https://batchtools.mlr-org.com/reference/showLog.md)
  [`getLog()`](https://batchtools.mlr-org.com/reference/showLog.md) :
  Inspect Log Files
- [`getErrorMessages()`](https://batchtools.mlr-org.com/reference/getErrorMessages.md)
  : Retrieve Error Messages
- [`grepLogs()`](https://batchtools.mlr-org.com/reference/grepLogs.md) :
  Grep Log Files for a Pattern

## Remove Jobs

- [`killJobs()`](https://batchtools.mlr-org.com/reference/killJobs.md) :
  Kill Jobs
- [`clearRegistry()`](https://batchtools.mlr-org.com/reference/clearRegistry.md)
  : Remove All Jobs
- [`removeExperiments()`](https://batchtools.mlr-org.com/reference/removeExperiments.md)
  : Remove Experiments

## Additional objects

- [`makeJob()`](https://batchtools.mlr-org.com/reference/JobExperiment.md)
  : Jobs and Experiments
- [`makeJobCollection()`](https://batchtools.mlr-org.com/reference/JobCollection.md)
  : JobCollection Constructor

## Cluster Functions

- [`cfKillJob()`](https://batchtools.mlr-org.com/reference/cfKillJob.md)
  : Cluster Functions Helper to Kill Batch Jobs
- [`cfBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfBrewTemplate.md)
  : Cluster Functions Helper to Write Job Description Files
- [`cfReadBrewTemplate()`](https://batchtools.mlr-org.com/reference/cfReadBrewTemplate.md)
  : Cluster Functions Helper to Parse a Brew Template
- [`cfHandleUnknownSubmitError()`](https://batchtools.mlr-org.com/reference/cfHandleUnknownSubmitError.md)
  : Cluster Functions Helper to Handle Unknown Errors
- [`makeClusterFunctions()`](https://batchtools.mlr-org.com/reference/makeClusterFunctions.md)
  : ClusterFunctions Constructor
- [`makeClusterFunctionsDocker()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsDocker.md)
  : ClusterFunctions for Docker
- [`makeClusterFunctionsHyperQueue()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsHyperQueue.md)
  : ClusterFunctions for HyperQueue
- [`makeClusterFunctionsInteractive()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsInteractive.md)
  : ClusterFunctions for Sequential Execution in the Running R Session
- [`makeClusterFunctionsLSF()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsLSF.md)
  : ClusterFunctions for LSF Systems
- [`makeClusterFunctionsMulticore()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsMulticore.md)
  : ClusterFunctions for Parallel Multicore Execution
- [`makeClusterFunctionsOpenLava()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsOpenLava.md)
  : ClusterFunctions for OpenLava
- [`makeClusterFunctionsSGE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSGE.md)
  : ClusterFunctions for SGE Systems
- [`makeClusterFunctionsSSH()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSSH.md)
  : ClusterFunctions for Remote SSH Execution
- [`makeClusterFunctionsSlurm()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSlurm.md)
  : ClusterFunctions for Slurm Systems
- [`makeClusterFunctionsSocket()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsSocket.md)
  : ClusterFunctions for Parallel Socket Execution
- [`makeClusterFunctionsTORQUE()`](https://batchtools.mlr-org.com/reference/makeClusterFunctionsTORQUE.md)
  : ClusterFunctions for OpenPBS/TORQUE Systems
- [`makeSubmitJobResult()`](https://batchtools.mlr-org.com/reference/makeSubmitJobResult.md)
  : Create a SubmitJobResult
- [`runHook()`](https://batchtools.mlr-org.com/reference/runHook.md) :
  Trigger Evaluation of Custom Function
- [`Worker`](https://batchtools.mlr-org.com/reference/Worker.md) :
  Create a Linux-Worker

## Miscellaneous

- [`addJobTags()`](https://batchtools.mlr-org.com/reference/Tags.md)
  [`removeJobTags()`](https://batchtools.mlr-org.com/reference/Tags.md)
  [`getUsedJobTags()`](https://batchtools.mlr-org.com/reference/Tags.md)
  : Add or Remove Job Tags
- [`btlapply()`](https://batchtools.mlr-org.com/reference/btlapply.md)
  [`btmapply()`](https://batchtools.mlr-org.com/reference/btlapply.md) :
  Synchronous Apply Functions
- [`ijoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md)
  [`ljoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md)
  [`rjoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md)
  [`ojoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md)
  [`sjoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md)
  [`ajoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md)
  [`ujoin()`](https://batchtools.mlr-org.com/reference/JoinTables.md) :
  Inner, Left, Right, Outer, Semi and Anti Join for Data Tables
- [`runOSCommand()`](https://batchtools.mlr-org.com/reference/runOSCommand.md)
  : Run OS Commands on Local or Remote Machines
- [`execJob()`](https://batchtools.mlr-org.com/reference/execJob.md) :
  Execute a Single Jobs
- [`doJobCollection()`](https://batchtools.mlr-org.com/reference/doJobCollection.md)
  : Execute Jobs of a JobCollection
- [`estimateRuntimes()`](https://batchtools.mlr-org.com/reference/estimateRuntimes.md)
  [`print(`*`<RuntimeEstimate>`*`)`](https://batchtools.mlr-org.com/reference/estimateRuntimes.md)
  : Estimate Remaining Runtimes

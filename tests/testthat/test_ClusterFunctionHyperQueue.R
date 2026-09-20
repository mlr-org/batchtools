test_that("clusterFunctionsHyperQueue", {
  skip_if(TRUE)
  skip_on_ci()
  skip_on_cran()

  reg = makeTestRegistry()
  reg$cluster.functions = makeClusterFunctionsHyperQueue()
  saveRegistry(reg)
  fun = function(x) {
    Sys.sleep(5)
    TRUE
  }
  ids = batchMap(fun, x = c(5, 5), reg = reg)
  submitJobs(1:2, reg = reg)
  waitForJobs(ids = ids, reg = reg)

  expect_data_table(findJobs(ids = ids, reg = reg), nrow = 2)
  expect_data_table(findRunning(reg = reg), nrow = 0L)
})

test_that("clusterFunctionsHyperQueue: killJob", {
  skip_if(TRUE)
  skip_on_ci()
  skip_on_cran()

  reg = makeTestRegistry()
  reg$cluster.functions = makeClusterFunctionsHyperQueue()
  saveRegistry(reg)
  fun = function(x) { Sys.sleep(5); TRUE }
  ids = batchMap(fun, x = c(5, 5), reg = reg)
  submitJobs(1:2, reg = reg)
  Sys.sleep(1)
  expect_data_table(killJobs(1, reg = reg), nrow = 1)
})

test_that("clusterFunctionsHyperQueue with resources", {
  skip_if(TRUE)
  skip_on_ci()
  skip_on_cran()

  reg = makeTestRegistry()
  reg$cluster.functions = makeClusterFunctionsHyperQueue()
  saveRegistry(reg)
  fun = function(x) {
    Sys.sleep(5)
    TRUE
  }
  ids = batchMap(fun, x = c(5, 5), reg = reg)
  submitJobs(1:2, reg = reg, resources = list(ncpus = 2, walltime = 10, memory = 5))
  waitForJobs(ids = ids, reg = reg)

  expect_data_table(findJobs(ids = ids, reg = reg), nrow = 2)
  expect_data_table(findRunning(reg = reg), nrow = 0L)
})

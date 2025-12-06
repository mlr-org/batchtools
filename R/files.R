dir = function(reg, what) {
  fs::path(fs::path_expand(reg$file.dir), what)
}

getResultFiles = function(reg, ids) {
  fs::path(dir(reg, "results"), sprintf("%i.rds", if (is.atomic(ids)) ids else ids$job.id))
}

getLogFiles = function(reg, ids) {
  job.hash = log.file = NULL
  tab = reg$status[list(ids), c("job.id", "job.hash", "log.file")]
  tab[is.na(log.file) & !is.na(job.hash), log.file := sprintf("%s.log", job.hash)]
  tab[!is.na(log.file), log.file := fs::path(dir(reg, "logs"), log.file)]$log.file
}

getJobFiles = function(reg, hash) {
  fs::path(reg$file.dir, "jobs", sprintf("%s.rds", hash))
}

getExternalDirs = function(reg, ids) {
  fs::path(dir(reg, "external"), if (is.atomic(ids)) ids else ids$job.id)
}

mangle = function(x) {
  sprintf("%s.rds", base32_encode(x, use.padding = FALSE))
}

unmangle = function(x) {
  base32_decode(stri_sub(x, to = -5L), use.padding = FALSE)
}

file_remove = function(x) {
  fs::file_delete(x[fs::file_exists(x)])

  while(any(i <- fs::file_exists(x))) {
    Sys.sleep(0.5)
    fs::file_delete(x[i])
  }
}

file_mtime = function(x) {
  fs::file_info(x)$modification_time
}

writeRDS = function(object, file, compress = "gzip", wait = 300) {
  # (a) Write to *.rds.tmp
  tmp_file <- sprintf("%s.tmp", file)
  saveRDS(object, file = tmp_file, version = 2L, compress = compress)

  # (b) Wait for it to be found
  if (wait > 0) waitForFile(tmp_file, timeout = wait)

  # (c) Assert file exists
  if (!file_test("-f", tmp_file)) {
    stop(sprintf("Failed to save to temporary RDS file: %s", sQuote(tmp_file)))
  }

  # (d) Remove old file, if it exists
  if (file_test("-f", file)) file_remove(file)

  # (e) Rename *.rds.tmp to *.rds
  file.rename(tmp_file, file)
  if (!file_test("-f", file)) {
    stop(sprintf("Failed to rename temporarily saved RDS file: %s -> %s",
      sQuote(tmp_file), sQuote(file)))
  }
  
  invisible(TRUE)
}

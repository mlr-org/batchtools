# Find a batchtools Configuration File

This functions returns the path to the first configuration file found in
the following locations:

1.  File “batchtools.conf.R” in the path specified by the environment
    variable “R_BATCHTOOLS_SEARCH_PATH”.

2.  File “batchtools.conf.R” in the current working directory.

3.  File “config.R” in the user configuration directory as reported by
    `rappdirs::user_config_dir("batchtools", expand = FALSE)` (depending
    on OS, e.g., on linux this usually resolves to
    “~/.config/batchtools/config.R”).

4.  “.batchtools.conf.R” in the home directory (“~”).

5.  “config.R” in the site config directory as reported by
    `rappdirs::site_config_dir("batchtools")` (depending on OS). This
    file can be used for admins to set sane defaults for a computation
    site.

## Usage

``` r
findConfFile()
```

## Value

\[`character(1)`\] Path to the configuration file or `NA` if no
configuration file was found.

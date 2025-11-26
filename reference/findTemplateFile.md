# Find a batchtools Template File

This functions returns the path to a template file on the file system.

## Usage

``` r
findTemplateFile(template)
```

## Arguments

- template:

  \[`character(1)`\]  
  Either a path to a brew template file (with extension “tmpl”), or a
  short descriptive name enabling the following heuristic for the file
  lookup:

  1.  “batchtools.\[template\].tmpl” in the path specified by the
      environment variable “R_BATCHTOOLS_SEARCH_PATH”.

  2.  “batchtools.\[template\].tmpl” in the current working directory.

  3.  “\[template\].tmpl” in the user config directory (see
      [`user_config_dir`](https://rappdirs.r-lib.org/reference/user_data_dir.html));
      on linux this is usually “~/.config/batchtools/\[template\].tmpl”.

  4.  “.batchtools.\[template\].tmpl” in the home directory.

  5.  “\[template\].tmpl” in the package installation directory in the
      subfolder “templates”.

## Value

\[`character`\] Path to the file or `NA` if no template template file
was found.

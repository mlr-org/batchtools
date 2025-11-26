# Create a Linux-Worker

[`R6Class`](https://r6.r-lib.org/reference/R6Class.html) to create local
and remote linux workers.

## Format

An [`R6Class`](https://r6.r-lib.org/reference/R6Class.html) generator
object

## Value

\[`Worker`\].

## Fields

- `nodename`:

  Host name. Set via constructor.

- `ncpus`:

  Number of CPUs. Set via constructor and defaults to a heuristic which
  tries to detect the number of CPUs of the machine.

- `max.load`:

  Maximum load average (of the last 5 min). Set via constructor and
  defaults to the number of CPUs of the machine.

- `status`:

  Status of the worker; one of “unknown”, “available”, “max.cpus” and
  “max.load”.

## Methods

- `new(nodename, ncpus, max.load)`:

  Constructor.

- `update(reg)`:

  Update the worker status.

- `list(reg)`:

  List running jobs.

- `start(reg, fn, outfile)`:

  Start job collection in file “fn” and output to “outfile”.

- `kill(reg, batch.id)`:

  Kill job matching the “batch.id”.

## Examples

``` r
if (FALSE) { # \dontrun{
# create a worker for the local machine and use 4 CPUs.
Worker$new("localhost", ncpus = 4)
} # }
```

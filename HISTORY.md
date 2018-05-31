## 2.5.0

- Add include_module parameter and functionality.
- Prepare for adoption.

## 2.4.7

- Clarify documentation.

## 2.4.6

- Allow specifying devices via a classifier and/or Hiera.
- Support the Puppet Resource API and its credential files.

## 2.4.5

- PDK 1.5

## 2.4.4

- Add classification guard.

## 2.4.3

- Add LICENSE to accommodate users who need it in a top-level file.
- Update Puppet documentation URLs.

## 2.4.2

- Minor changes.

## 2.4.1

- Namespace custom facts.
- Prefer os.family fact over legacy osfamily fact.

## 2.4.0

- Specify '--verbose' by default.
- Deprecate 'run_via_exec' parameter

## 2.3.7

- Use ensure_resource to prevent duplicate resource for facter/facts.s path (credit: Kris Amundson).

## 2.3.6

- Replace reference to run_via_cron with run_interval (credit: Kris Amundson).

## 2.3.5

- Minor changes.

## 2.3.4

- Sanitize

## 2.3.3

- Rewrite task using methods
- Update run_interval function

## 2.3.1

- Typo in README.
- Tune run_interval.

## 2.3.0

- Restore run_interval parameter for cron and scheduled_task.

## 2.2.0

- Abstract cron and scheduled_task.
- Correct fact location on Windows.

## 2.1.2

- Added documentation.
- Tuneup cron, and prepare a scheduled_task.

## 2.1.1

Minor changes.

- Cleanup parameter handling.

## 2.1.0

Parameter changes.

- Rename the autorun parameter to run_via_exec.
- Implement a beta run_via_cron parameter.

## 2.0.1

- Fix anchor in README.
- Simplify run.

### Summary

Minor changes.

## 2.0.0

- Add support for tasks.
- Rename the run parameter to autorun.
- Change structured fact format from array to hash.
- Fully qualify the path to the test command.
- Normalize the waitforcert and user parameters of the puppet device command.

### Summary

This release adds support for tasks, and uses Puppet Development Kit (PDK).

## 1.1.1

### Summary

Minor changes.

#### Changed

- Test version to choose between hiera_hash and lookup.
- Use show_diff=false in concat to not log changes to device.conf.

## 1.1.0

### Summary

Minor changes.

#### Changed

- Use hiera_hash to improve compatibility.
- Use iteration instead of create_resource to improve readability.

## 1.0.9

### Summary

This release allows users to declare devices as a hash of hashes in Hiera.

#### Features/Improvements

- Implement a CHANGELOG.
- Adds support for declaring devices in Hiera.

## Release 2.3.4

- Sanitize

## Release 2.3.3

- Rewrite task using methods
- Update run_interval function

## Release 2.3.1

- Typo in README.
- Tune run_interval.

## Release 2.3.0

- Restore run_interval parameter for cron and scheduled_task.

## Release 2.2.0

- Abstract cron and scheduled_task.
- Correct fact location on Windows.

## Release 2.1.2

- Added documentation.
- Tuneup cron, and prepare a scheduled_task.

## Release 2.1.1

Minor changes.

- Cleanup parameter handling.

## Release 2.1.0

Parameter changes.

- Rename the autorun parameter to run_via_exec.
- Implement a beta run_via_cron parameter.

## Release 2.0.1

- Fix anchor in README.
- Simplify run.

### Summary

Minor changes.

## Release 2.0.0

- Add support for tasks.
- Rename the run parameter to autorun.
- Change structured fact format from array to hash.
- Fully qualify the path to the test command.
- Normalize the waitforcert and user parameters of the puppet device command.

### Summary

This release adds support for tasks, and uses Puppet Development Kit (PDK).

## Release 1.1.1

### Summary

Minor changes.

#### Changed

- Test version to choose between hiera_hash and lookup.
- Use show_diff=false in concat to not log changes to device.conf.

## Release 1.1.0

### Summary

Minor changes.

#### Changed

- Use hiera_hash to improve compatibility.
- Use iteration instead of create_resource to improve readability.

## Release 1.0.9

### Summary

This release allows users to declare devices as a hash of hashes in Hiera.

#### Features/Improvements

- Implement a CHANGELOG.
- Adds support for declaring devices in Hiera.

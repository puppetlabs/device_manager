## Release 2.0.1

- Fix anchor in README.
- Simplify run.

### Summary

Minor changes.

## Release 2.0.0

- Add support for tasks.
- Rename the run paramater to autorun.
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

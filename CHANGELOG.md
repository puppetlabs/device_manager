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

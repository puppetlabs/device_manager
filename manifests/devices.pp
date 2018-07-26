# device_manager::devices
#
# Configure devices and device defaults through data.
# Use either keys in Hiera, or parameters in the Classifier.
# If the same configuration is specified in both, the Classifier wins.
#
# See examples/devices.yaml
#
# @summary Configure devices and defaults through data.

class device_manager::devices(
  Hash $devices  = {},
  Hash $defaults = {},
) {

  # Validate node.

  unless has_key($facts, 'aio_agent_version') {
    fail("Classification Error: 'device_manager::devices' declared on a device instead of an agent.")
  }

  # Avoid the Hiera 5 'hiera_hash is deprecated' warning.

  if ( (versioncmp($::clientversion, '4.9.0') >= 0) and (! defined('$::serverversion') or versioncmp($::serverversion, '4.9.0') >= 0) ) {
    $hiera_devices  = lookup('device_manager::devices', Hash, 'hash', {})
    $hiera_defaults = lookup('device_manager::defaults', Hash, 'hash', {})
  } else {
    $hiera_devices  = hiera_hash('device_manager::devices', {})
    $hiera_defaults = hiera_hash('device_manager::defaults', {})
  }

  # Combine data from Hiera and the Classifier.

  $_devices = $hiera_devices + $devices
  $_defaults = deep_merge($hiera_defaults, $defaults)

  $_devices.each |$title, $_device| {

    $_type = device_manager::value_or_default('type', $_device, $_defaults)

    # Use the type to identify type-level defaults.

    $_credentials = device_manager::merge_default('credentials', $_device, $_defaults, $_type)

    $_debug          = device_manager::value_or_default('debug',          $_device, $_defaults, $_type)
    $_run_interval   = device_manager::value_or_default('run_interval',   $_device, $_defaults, $_type)
    $_run_via_exec   = device_manager::value_or_default('run_via_exec',   $_device, $_defaults, $_type)
    $_include_module = device_manager::value_or_default('include_module', $_device, $_defaults, $_type)

    device_manager { $title:
      name           => $_device['name'],
      type           => $_type,
      url            => $_device['url'],
      credentials    => $_credentials,
      debug          => $_debug,
      run_interval   => $_run_interval,
      run_via_exec   => $_run_via_exec,
      include_module => $_include_module,
    }
  }
}

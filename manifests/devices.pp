# device_manager::devices
#
# Configure devices and defaults through data.
# Use either keys in Hiera, or parameters in the Classifier.
# If the same configuration is specified in both, the Classifier wins.
#
# @summary Configure devices and defaults through data.
#
# @example Keys in Hiera:
#
#   ---
#   device_manager::devices:
#     bigip1.example.com:
#       type:         'f5'
#       url:          'https://admin:fffff55555@10.0.1.245/'
#     bigip2.example.com:
#       type:         'f5'
#       url:          'https://admin:fffff55555@10.0.2.245/'
#       run_interval: 60
#
#   device_manager::defaults:
#     run_interval: 30
#     f5:
#       run_interval: 45
#
# @example Parameters in the Classifier:
#
#   class { 'device_manager::devices':
#     devices => {
#       'bigip1.example.com' => {
#         type => 'f5',
#         url  => 'https://admin:fffff55555@10.0.1.245/',
#       },
#       'bigip2.example.com' => {
#         type => 'f5',
#         url  => 'https://admin:fffff55555@10.0.2.245/',
#         run_interval => 60,
#       },
#     },
#     defaults => {
#       run_interval => 30,
#       f5 => { 
#         run_interval => 45,
#       },
#     }
#   }

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

  $_devices.each |$title, $device| {

    $_type           = device_manager::value_or_default('type',           $device, $_defaults)

    # Pass the type to value_or_default() and merge_default() to identify type-level defaults.

    $_debug          = device_manager::value_or_default('debug',          $device, $_defaults, $_type)
    $_include_module = device_manager::value_or_default('include_module', $device, $_defaults, $_type)
    $_run_interval   = device_manager::value_or_default('run_interval',   $device, $_defaults, $_type)
    $_run_via_exec   = device_manager::value_or_default('run_via_exec',   $device, $_defaults, $_type)

    $_credentials    = device_manager::merge_default('credentials',       $device, $_defaults, $_type)

    device_manager { $title:
      name           => $device['name'],
      url            => $device['url'],
      credentials    => $_credentials,
      type           => $_type,
      debug          => $_debug,
      include_module => $_include_module,
      run_interval   => $_run_interval,
      run_via_exec   => $_run_via_exec,
    }
  }
}

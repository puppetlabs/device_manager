# device_manager::devices
#
# Configure multiple devices and device defaults via data.
#
# Use either keys in Hiera, or parameters in the Classifier.
# If the same configuration is specified in both, the Classifier wins.
#
# See examples/devices.yaml
#
# @summary Configure multiple devices and device defaults via data.

class device_manager::devices (
  Hash $devices  = {},
  Hash $defaults = {},
) {

  # Initialize the concat resources used by conf and fact.
  # This allows an empty device_manager::devices hash to clear undeclared devices from conf and facts.
  # Note that concat is not used by run, resulting in orphaned Cron (or Scheduled Task) resources.
  # Best practice is to ensure => absent via device defaults instead of an empty device_manager::devices hash.

  include device_manager::conf
  include device_manager::fact

  # Avoid the Hiera 5 'hiera_hash is deprecated' warning.

  if ( (versioncmp($::clientversion, '4.9.0') >= 0) and (! defined('$::serverversion') or versioncmp($::serverversion, '4.9.0') >= 0) ) {
    $hiera_devices  = lookup('device_manager::devices', Hash, 'hash', {})
    $hiera_defaults = lookup('device_manager::devices::defaults', Hash, 'hash', {})
  } else {
    $hiera_devices  = hiera_hash('device_manager::devices', {})
    $hiera_defaults = hiera_hash('device_manager::devices::defaults', {})
  }

  # Combine data from Hiera and the Classifier.

  $_devices = $hiera_devices + $devices
  $_defaults = deep_merge($hiera_defaults, $defaults)

  $_devices.each |$title, $_device| {

    # Note: type generates an error when uses as a bareword hash key name: Error: Syntax error at ']'
    # Possibly reserved as per: https://puppet.com/docs/puppet/latest/lang_reserved.html
    $key = 'type'

    if ($_device[$key] != undef) {
      $_type = $_device[$key]
    } else {
      $_type = $_defaults[$key]
    }

    if ($_type == undef) {
      fail('Parameter Error: type is required')
    }

    # Use the type to identify type-level defaults.

    if has_key($_defaults, $_type) {
      $_device_type_defaults = $_defaults[$_type]
    } else {
      $_device_type_defaults = {}
    }

    # Merge defaults and parameters. Note: the rightmost hash takes precedence.

    $params = deep_merge($_defaults, $_device_type_defaults, $_device)

    device_manager { $title:
      ensure         => $params['ensure'],
      name           => $params['name'],
      type           => $params['type'],
      url            => $params['url'],
      credentials    => $params['credentials'],
      debug          => $params['debug'],
      run_interval   => $params['run_interval'],
      run_via_exec   => $params['run_via_exec'],
      include_module => $params['include_module'],
      run_user       => $params['run_user'],
      run_group      => $params['run_group'],
    }
  }
}

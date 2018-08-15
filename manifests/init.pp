# AKA: device_manager::device
#
# Configure a single device.
#
# When modifying the parameter list, also modify device_manager::devices in devices.pp.
#
# @summary Configure a single device.

define device_manager (
  Optional[String]  $type           = undef,
  Optional[String]  $url            = undef,
  Optional[Hash]    $credentials    = undef,
  Optional[Boolean] $debug          = undef,
  Optional[Integer] $run_interval   = undef,
  Optional[Boolean] $run_via_exec   = undef,
  Optional[Boolean] $include_module = undef,
  Optional[String]  $ensure         = undef,
) {

  # Validate node.

  unless has_key($facts, 'aio_agent_version') {
    fail("Classification Error: 'device_manager' declared on a device instead of an agent.")
  }

  # Define defaults.

  $resource_defaults = {
    'ensure'         => 'present',
    'type'           => undef,
    'url'            => '',
    'credentials'    => {},
    'debug'          => false,
    'run_interval'   => 0,
    'run_via_exec'   => false,
    'include_module' => true
  }

  # Avoid the Hiera 5 'hiera_hash is deprecated' warning.

  if ( (versioncmp($::clientversion, '4.9.0') >= 0) and (! defined('$::serverversion') or versioncmp($::serverversion, '4.9.0') >= 0) ) {
    $defaults = lookup('device_manager::defaults', Hash, 'hash', {})
  } else {
    $defaults = hiera_hash('device_manager::defaults', {})
  }

  # Note: type cannot be a bare word hash key name: $defaults[type]
  $key = 'type'

  if ($type != undef) {
    $_type = $type
  } else {
    $_type = $defaults[$key]
  }

  if ($_type == undef) {
    fail('Parameter Error: type is required')
  }

  # Use the type to identify type-level defaults.

  if has_key($defaults, $_type) {
    $device_type_defaults = $defaults[$_type]
  } else {
    $device_type_defaults = {}
  }

  # Define parameters.

  $resource_params = delete_undef_values ({
    'ensure'         => $ensure,
    'type'           => $type,
    'url'            => $url,
    'credentials'    => $credentials,
    'debug'          => $debug,
    'run_interval'   => $run_interval,
    'run_via_exec'   => $run_via_exec,
    'include_module' => $include_module,
  })

  # Merge defaults and parameters. Note: the rightmost hash takes precedence.

  $params = deep_merge($resource_defaults, $defaults, $device_type_defaults, $resource_params)

  # Validate parameters.

  if (($params['run_interval'] > 0) and ($params['run_via_exec'] == true)) {
    fail('Parameter Error: run_interval and run_via_exec are mutually-exclusive')
  }

  if (!empty($params['credentials']) and ($params['url'] != '')) {
    fail('Parameter Error: credentials and url are mutually-exclusive')
  }

  if (empty($params['credentials']) and ($params['url'] == '')) {
    fail('Parameter Error: either credentials or url must be specified')
  }

  # Add, update, or remove this device in the deviceconfig file.

  device_manager::conf::device { $name:
    ensure      => $params['ensure'],
    type        => $params['type'],
    url         => $params['url'],
    credentials => $params['credentials'],
    debug       => $params['debug'],
  }

  # Add, update, or remove this device in the devices structured fact.

  device_manager::fact::device { $name:
    ensure => $params['ensure'],
  }

  # Add, update, or remove a `puppet device` Cron (or Scheduled Task) for this device.

  if ($facts['os']['family'] == 'windows') {
    device_manager::run::via_scheduled_task::device { $name:
      ensure       => $params['ensure'],
      run_interval => $params['run_interval'],
    }
  } else {
    device_manager::run::via_cron::device { $name:
      ensure       => $params['ensure'],
      run_interval => $params['run_interval'],
    }
  }

  # Optionally, declare a `puppet device` Exec for this device.

  if (($params['ensure'] == present) and ($params['run_via_exec'] == true)) {
    device_manager::run::via_exec::device { $name: }
  }

  # Device modules often implement a base class that implements an install class.
  # Automatically include that base class to install any requirements of the module.

  if (($params['ensure'] == 'present') and ($params['include_module'] == true) and defined($params['type'])) {
    include $params['type']
  }
}

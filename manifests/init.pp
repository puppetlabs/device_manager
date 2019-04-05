# AKA: device_manager::device
#
# Configure a single device on a proxy.
#
# When modifying the parameter list, also modify device_manager::devices in devices.pp.
#
# @summary Configure a single device.

define device_manager (
  String[1]              $type,
  String                 $url            = '',
  Hash                   $credentials    = {},
  Boolean                $debug          = false,
  Integer[0,1440]        $run_interval   = 0,
  Boolean                $run_via_exec   = false,
  Boolean                $include_module = true,
  Enum[present, absent]  $ensure         = present,
) {

  # Validate parameters.

  if (($run_interval > 0) and ($run_via_exec == true)) {
    fail('Parameter Error: run_interval and run_via_exec are mutually-exclusive')
  }

  if (!empty($credentials) and ($url != '')) {
    fail('Parameter Error: credentials and url are mutually-exclusive')
  }

  if (($ensure == present) and empty($credentials) and ($url == '')) {
    fail('Parameter Error: either credentials or url must be specified')
  }

  # Add, update, or remove this device in the deviceconfig file.

  device_manager::conf::device { $name:
    ensure      => $ensure,
    type        => $type,
    url         => $url,
    credentials => $credentials,
    debug       => $debug,
  }

  # Add, update, or remove this device in the devices structured fact.

  device_manager::fact::device { $name:
    ensure => $ensure,
  }

  # Add, update, or remove a `puppet device` Cron (or Scheduled Task) for this device.

  if ($facts['os']['family'] == 'windows') {
    device_manager::run::via_scheduled_task::device { $name:
      ensure       => $ensure,
      run_interval => $run_interval,
    }
  } else {
    device_manager::run::via_cron::device { $name:
      ensure       => $ensure,
      run_interval => $run_interval,
    }
  }

  # Optionally, declare a `puppet device` Exec for this device.

  if (($ensure == present) and ($run_via_exec == true)) {
    device_manager::run::via_exec::device { $name: }
  }

  # Some device modules implement a base class that implements an install class.
  # Optionally, include that base class to install any requirements of the device module.

  if (($ensure == present) and ($include_module == true) and defined($type)) {
    include $type
  }
}

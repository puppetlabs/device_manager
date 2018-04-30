# Configure this device.

define puppet_device (
  String[1]              $type,
  String                 $url          = '',
  Hash                   $credentials  = {},
  Boolean                $debug        = false,
  Integer[0,1440]        $run_interval = 0,
  Boolean                $run_via_exec = false,
  Enum[present, absent]  $ensure       = present,
) {

  # Validate node.

  unless has_key($facts, 'aio_agent_version') {
    fail("Classification Error: 'puppet_device' declared on a device instead of an agent.")
  }

  # Validate parameters.

  if ($run_interval > 0 and $run_via_exec) {
    fail('Parameter Error: run_interval and run_via_exec are mutually-exclusive')
  }

  if (!empty($credentials) and $url != '') {
    fail('Parameter Error: credentials and url are mutually-exclusive')
  }

  if (empty($credentials) and $url == '') {
    fail('Parameter Error: either credentials or url must be specified')
  }

  # Add, update, or remove this device in the deviceconfig file.

  puppet_device::conf::device { $name:
    ensure      => $ensure,
    type        => $type,
    url         => $url,
    credentials => $credentials,
    debug       => $debug,
  }

  # Add, update, or remove this device in the puppet_devices structured fact.

  puppet_device::fact::device { $name:
    ensure => $ensure,
  }

  # Add, update, or remove a `puppet device` Cron (or Scheduled Task) for this device.

  if ($facts['os']['family'] == 'windows') {

    puppet_device::run::via_scheduled_task::device { $name:
      ensure       => $ensure,
      run_interval => $run_interval,
    }

  } else {

    puppet_device::run::via_cron::device { $name:
      ensure       => $ensure,
      run_interval => $run_interval,
    }

  }

  # Optionally, declare a `puppet device` Exec for this device.

  if ($run_via_exec and ($ensure == present)) {
    puppet_device::run::via_exec::device { $name: }
  }

}

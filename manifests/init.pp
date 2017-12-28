# Manage this device.

define puppet_device (
  String[1]              $type,
  String[5]              $url,
  Boolean                $debug        = false,
  Boolean                $run_via_cron = false,
  Boolean                $run_via_exec = false,
  Enum[present, absent]  $ensure       = present,
) {

  # Validate parameters.

  if ($run_via_cron and $run_via_exec) {
    fail('Parameter Error: run_via_cron and run_via_exec are mutually-exclusive')
  }

  # Add, update, or remove this device in the deviceconfig file.

  puppet_device::conf::device { $name:
    ensure => $ensure,
    type   => $type,
    url    => $url,
    debug  => $debug,
  }

  # Add, update, or remove this device in the puppet_devices structured fact.

  puppet_device::fact::device { $name:
    ensure => $ensure,
  }

  # Add, update, or remove a `puppet device` cron (or scheduled task) for this device.

  if ($facts['osfamily'] != 'windows') {

    puppet_device::run::via_cron::device { $name:
      ensure       => $ensure,
      schedule_run => $run_via_cron,
    }

  } else {

    puppet_device::run::via_scheduled_task::device { $name:
      ensure       => $ensure,
      schedule_run => $run_via_cron,
    }

  }

  # Optionally, declare a `puppet device` Exec for this device.

  if ($run_via_exec and ($ensure == present)) {
    puppet_device::run::via_exec::device { $name: }
  }

}
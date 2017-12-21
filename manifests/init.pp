# Manage this device.

define puppet_device (
  String                $type,
  String                $url,
  Boolean               $debug               = false,
  Boolean               $run_via_cron        = false,
  Boolean               $run_via_exec        = false,
  Optional[String]      $run_via_cron_hour   = absent,
  Optional[String]      $run_via_cron_minute = absent,
  Enum[present, absent] $ensure              = present,
) {

  # Validate parameters.

  if ($run_via_cron and $run_via_exec) {
    fail('Parameter Error: run_via_cron and run_via_exec are mutually-exclusive')
  }

  if ($run_via_cron and $run_via_cron_hour == absent and $run_via_cron_minute == absent) {
    fail('Parameter Error: run_via_cron_hour and run_via_cron_minute cannot both be absent or undefined')
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

  # Add, update, or remove a `puppet device` Cron for this device.

  puppet_device::run::via_cron::device { $name:
    ensure              => $ensure,
    run_via_cron        => $run_via_cron,
    run_via_cron_hour   => $run_via_cron_hour,
    run_via_cron_minute => $run_via_cron_minute,
  }

  # Optionally, add a `puppet device` Exec for this device.

  if ($run_via_exec and ($ensure == present)) {
    puppet_device::run::via_exec::device { $name: }
  }

}
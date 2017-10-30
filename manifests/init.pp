# Manage devices.

# TODO: Implement either/or for run_via_exec and run_device_via_cron.

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

  if ($run_via_cron and $run_via_exec) {
    fail('Parameter Error: run_via_cron and run_via_exec are mutually-exclusive')
  }

  if ($run_via_cron and $run_via_cron_hour == absent and $run_via_cron_minute == absent) {
    fail('Parameter Error: run_via_cron_hour and run_via_cron_minute cannot both be absent or undefined')
  }

  puppet_device::conf::device { $name:
    ensure => $ensure,
    type   => $type,
    url    => $url,
    debug  => $debug,
  }

  puppet_device::fact::device { $name:
    ensure => $ensure,
  }

  puppet_device::run::via_cron::device { $name:
    ensure              => $ensure,
    run_via_cron        => $run_via_cron,
    run_via_cron_hour   => $run_via_cron_hour,
    run_via_cron_minute => $run_via_cron_minute,
  }

  if ($run_via_exec and ($ensure == present)) {
    puppet_device::run::via_exec::device { $name: }
  }

}
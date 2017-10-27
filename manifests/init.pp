# Manage devices.

# TODO: Implement either/or for run_via_exec and run_device_via_cron.

define puppet_device (
  String                    $type,
  String                    $url,
  Boolean                   $debug = false,
  Boolean                   $run_via_exec = false,
  Boolean                   $run_via_cron = false,
  Enum['present', 'absent'] $ensure = 'present',
) {

  puppet_device::conf::device { $name:
    ensure => $ensure,
    type   => $type,
    url    => $url,
    debug  => $debug,
  }

  puppet_device::fact::device { $name:
    ensure => $ensure,
  }

  if ($run_via_exec and ($ensure == 'present')) {
    puppet_device::run::via_exec::device { $name: }
  }

  if ($run_via_cron and ($ensure == 'present')) {
    puppet_device::run::via_cron::device { $name: }
  }

}


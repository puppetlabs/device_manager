# Manage devices.

define puppet_device (
  String                    $type,
  String                    $url,
  Boolean                   $debug = false,
  Boolean                   $run  = false,
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

  if ($run and ($ensure == 'present')) {
    puppet_device::run::device { $name: }
  }

}


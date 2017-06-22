# Manage devices.

define puppet_device (
  String                    $type,
  String                    $url,
  Boolean                   $debug = false,
  Boolean                   $run  = false,
  Enum['present', 'absent'] $ensure = 'present',
) {

  puppet_device::conf::device { $title:
    ensure => $ensure,
    type   => $type,
    url    => $url,
    debug  => $debug,
  }

  puppet_device::fact::device { $title:
    ensure => $ensure,
  }

  if ($run and ($ensure == 'present')) {

    if ($facts['os']['family'] == 'windows') {
      windows_installdir = $facts['env_windows_installdir']
      puppet_command = "${windows_installdir}/puppet/bin/puppet"
    } else {
      puppet_command = '/opt/puppetlabs/puppet/bin/puppet'
    }

    exec {"run puppet_device target ${title}":
      command => "{$puppet_command} device --target ${title} --user=root --waitforcert 0",
      require => Puppet_device::Conf::Device[$title],
    }
  }

}

# Perform a 'puppet device --target' run with every 'puppet agent' run.

define puppet_device::run::device {

  if ($facts['osfamily'] == 'windows') {
    $windows_installdir = $facts['env_windows_installdir']
    $puppet_command = "\"${windows_installdir}/puppet\""
  } else {
    $puppet_command = '/opt/puppetlabs/puppet/bin/puppet'
  }

  $targetable_devices = (versioncmp($::puppetversion,'5.0.0') >= 0)

  if $targetable_devices {
    exec {"init puppet_device target ${title}":
      command => "${puppet_command} device --target ${title} --user=root --waitforcert 0",
      require => Puppet_device::Conf::Device[$title],
      unless  => "test -f ${::puppet_vardir}/devices/${title}/ssl/certs/${title}.pem",
      tag     => ['run_puppet_device', "run_puppet_device_${title}"],
    }
    exec {"run puppet_device target ${title}":
      command => "${puppet_command} device --target ${title} --waitforcert 0",
      require => Puppet_device::Conf::Device[$title],
      onlyif  => "test -f ${::puppet_vardir}/devices/${title}/ssl/certs/${title}.pem",
      tag     => ['run_puppet_device', "run_puppet_device_${title}"],
    }
  } else {
    include puppet_device::run
  }

}

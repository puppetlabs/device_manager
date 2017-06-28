# Perform a 'puppet device' run with every 'puppet agent' run.

class puppet_device::run {

  if ($facts['osfamily'] == 'windows') {
    $windows_installdir = $facts['env_windows_installdir']
    $puppet_command = "\"${windows_installdir}/puppet\""
  } else {
    $puppet_command = '/opt/puppetlabs/puppet/bin/puppet'
  }

  exec {'run puppet_device':
    command => "${puppet_command} device --user=root --waitforcert 0",
    tag     => 'run_puppet_device',
  }

}

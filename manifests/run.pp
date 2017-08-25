# Conditional class.

class puppet_device::run {

  if ($facts['osfamily'] == 'windows') {
    $command = "\"${facts['env_windows_installdir']}/puppet\""
  } else {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
  }

  $targetable = (versioncmp($::puppetversion,'5.0.0') >= 0)

}

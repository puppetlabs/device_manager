# Conditional class.

# TODO: Use facts['env_windows_installdir' on Windows.

class puppet_device::run {

  if ($facts['osfamily'] == 'windows') {
    $command = '"C:\Program Files\Puppet Labs\Puppet\bin\puppet"'
  } else {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
  }

  $targetable = (versioncmp($::puppetversion,'5.0.0') >= 0)

}

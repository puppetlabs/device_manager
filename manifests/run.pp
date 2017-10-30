# Conditional class.

# TODO: Use facts['env_windows_installdir'] on Windows.
# TODO: Remove '--user=root' after PUP-1391 is resolved.

class puppet_device::run {

  if ($facts['osfamily'] == 'windows') {
    $command = '"C:\Program Files\Puppet Labs\Puppet\bin\puppet device" --user=root'
  } else {
    $command = '/opt/puppetlabs/puppet/bin/puppet device --user=root'
  }

  $targetable = (versioncmp($::puppetversion,'5.0.0') >= 0)

}

# Define variables used by individual Cron and Exec resources.
# @api private

class puppet_device::run {

  if ($facts['osfamily'] != 'windows') {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
  } else {
    $command = "${::env_windows_installdir}\\bin\\puppet"
  }

  # PUP-1391 Puppet 5.4.0 does not require '--user=root'.
  if (versioncmp($::puppetversion, '5.4.0') >= 0) {
    $user = ''
  } else {
    $user = '--user=root'
  }

  # TODO: Consider removing multiple spaces using join(), delete(), rstrip().
  $arguments = "device --waitforcert=0 ${user} --verbose"

  # PUP-7412 Puppet 5.4.0 introduces '--target=root'.
  $targetable = (versioncmp($::puppetversion, '5.0.0') >= 0)

  $random_minute = sprintf('%02d', fqdn_rand(59, 'puppet_device'))
}

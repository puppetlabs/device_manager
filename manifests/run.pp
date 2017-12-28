# Define variables used by individual Cron and Exec resources.
# @api private

class puppet_device::run {

  if ($facts['osfamily'] != 'windows') {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
  } else {
    $command = "${::env_windows_installdir}\\bin\\puppet"
  }

  # PUP-1391
  if (versioncmp($::puppetversion, '5.4.0') >= 0) {
    $arguments = 'device --waitforcert=0'
  } else {
    $arguments = 'device --waitforcert=0 --user=root'
  }

  # PUP-7412
  $targetable = (versioncmp($::puppetversion, '5.0.0') >= 0)

  $random_minute = sprintf('%02d', fqdn_rand(59, 'puppet_device'))
}

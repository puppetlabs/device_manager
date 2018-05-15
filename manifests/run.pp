# Define variables used by individual Cron and Exec resources.
# @api private

class device_manager::run {

  if ($facts['os']['family'] == 'windows') {
    $command = "${::env_windows_installdir}\\bin\\puppet"
  } else {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
  }

  # PUP-1391 Puppet 5.4.0 does not require '--user=root'.
  if (versioncmp($::puppetversion, '5.4.0') >= 0) {
    $user = ''
  } else {
    $user = '--user=root'
  }

  # TODO: Consider removing multiple spaces using join(), delete(), rstrip().
  $arguments = "device --waitforcert=0 ${user} --verbose"

  # PUP-7412 Puppet 5.0.0 introduces '--target=root'.
  $targetable = (versioncmp($::puppetversion, '5.0.0') >= 0)

  $random_minute = sprintf('%02d', fqdn_rand(59, 'device_manager'))
}

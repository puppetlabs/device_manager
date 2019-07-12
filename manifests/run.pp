# Define variables used by individual Cron and Exec resources.
# @api private

class device_manager::run {

  if ($facts['os']['family'] == 'windows') {
    $command = "${::env_windows_installdir}\\bin\\puppet"
    $logdest = 'eventlog'
  } else {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
    $logdest = 'syslog'
  }

  # PUP-1391 Puppet 5.4.0 eliminates the need for '--user=root'.
  if (versioncmp($::puppetversion, '5.4.0') < 0) {
    $optional_user = ' --user=root'
  } else {
    $optional_user = ''
  }

  $arguments = "device --verbose --waitforcert=0 --logdest=${logdest}${optional_user}"

  # PUP-7412 Puppet 5.0.0 introduces '--target=<device>'.
  $targetable = (versioncmp($::puppetversion, '5.0.0') >= 0)

  $random_minute = sprintf('%02d', fqdn_rand(59, 'device_manager'))
}

# Define variables used by individual Cron and Exec resources.
# @api private

class device_manager::run {

  include device_manager::conf

  $owner = $device_manager::conf::owner
  $group = $device_manager::conf::group

  if ($facts['os']['family'] == 'windows') {
    $command = "${::env_windows_installdir}\\bin\\puppet"
    $logdest = 'eventlog'
  } else {
    $command = '/opt/puppetlabs/puppet/bin/puppet'
    $logdest = 'syslog'
  }

  # PUP-1391 Puppet 5.4.0 does not require '--user=root'.
  if (versioncmp($::puppetversion, '5.4.0') >= 0) {
    $user = ''
  } else {
    $user = '--user=root'
  }

  $arguments = "device ${user} --waitforcert=0 --verbose --logdest ${logdest}"

  # PUP-7412 Puppet 5.0.0 introduces '--target=<device>'.
  $targetable = (versioncmp($::puppetversion, '5.0.0') >= 0)

  $random_minute = sprintf('%02d', fqdn_rand(59, 'device_manager'))

}

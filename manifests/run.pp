# Define variables used by individual Cron and Exec resources.
# @api private

class puppet_device::run {

  # PUP-1391
  if (versioncmp($::puppetversion, '5.4.0') >= 0) {
    $user_root = ''
  } else {
    $user_root = '--user=root'
  }

  if ($facts['osfamily'] == 'windows') {
    $command = "\"${::env_windows_installdir}\\bin\\puppet device\" ${user_root}"
  } else {
    $command = "/opt/puppetlabs/puppet/bin/puppet device ${user_root}"
  }

  # PUP-7412
  $targetable = (versioncmp($::puppetversion, '5.0.0') >= 0)

}

# Perform a 'puppet device' run for all devices via cron.
# @api private

# This class is declared via include to create just one Cron resource for all devices.

class device_manager::run::via_cron::untargeted {

  cron { 'run puppet device':
    ensure  => present,
    command => "${device_manager::run::command} ${device_manager::run::arguments}",
    user    => $device_manager::run::owner,
    hour    => '*',
    minute  => $device_manager::run::random_minute,
  }

}

# Perform a 'puppet device' run for all devices via cron.
# @api private

# This class is declared via include to create just one Cron resource for all devices.

class puppet_device::run::via_cron::untargeted {

  $minute = $puppet_device::run::random_minute

  cron { 'run puppet_device':
    ensure  => present,
    command => "${puppet_device::run::command} ${puppet_device::run::arguments}",
    user    => 'root',
    hour    => '*',
    minute  => $minute,
  }

}

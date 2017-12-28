# Perform a 'puppet device' run for all devices via cron.
# @api private

# This class is declared via include to create just one Cron resource for all devices.
# But then the parameters specified in the calling class are not accessible.
# Use reasonable defaults.

class puppet_device::run::via_cron::untargeted {
  # notify {"Warning: run_interval uses a default of (${puppet_device::run::interval}) where 'puppet device' does not implement '--target'":}

  $minute = $puppet_device::run::random_minute

  cron { 'run puppet_device':
    ensure  => present,
    command => "${puppet_device::run::command} ${puppet_device::run::arguments}",
    user    => 'root',
    hour    => '*',
    minute  => $minute,
  }

}

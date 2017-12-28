# Perform a 'puppet device' run for all devices via a scheduled task.
# @api private

# This class is declared via include to create just one Scheduled Task resource for all devices.
# But then the parameters specified in the calling class are not accessible.
# Use reasonable defaults.

class puppet_device::run::via_scheduled_task::untargeted {
  # notify {"Warning: run_interval uses a default of (${puppet_device::run::interval}) where 'puppet device' does not implement '--target'":}

  $start_time = "00:${puppet_device::run::random_minute}"

  scheduled_task { 'run puppet_device':
    ensure    => present,
    command   => $puppet_device::run::command,
    arguments => $puppet_device::run::arguments,
    trigger   => {
      schedule         => 'daily',
      minutes_interval => '60',
      start_time       => $start_time,
    }
  }

}

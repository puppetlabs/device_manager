# Perform a 'puppet device' run for all devices via a scheduled task.
# @api private

# This class is declared via include to create just one Scheduled Task resource for all devices.

# But the parameters specified in the calling class are not accessible,
# and even if so, only one (the first) device's parameters would be applied.
# Rather than deviating and specifying default parameters, don't create the resource.

class puppet_device::run::via_scheduled_task::untargeted {
  notify {"Warning: via_scheduled_task is not supported where 'puppet device' does not implement '--target'":}
}

# Perform a 'puppet device' run for all devices via cron.
# @api private

# This class is declared via include to create just one Cron resource for all devices.

# But the parameters specified in the calling class are not accessible,
# and even if so, only one (the first) device's parameters would be applied.
# Rather than deviating and specifying default parameters, don't create the resource.

class puppet_device::run::via_cron::untargeted {
  notify {"Warning: run_via_cron is not supported where 'puppet device' does not implement '--target'":}
}

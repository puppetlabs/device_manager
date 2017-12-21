# Perform a 'puppet device' run for all devices via cron.
# @api private

# This class needs to be declared via include to prevent duplicate Cron resources.
# But the parameters specified in the calling 'device' defined class are not accessible.
# And if multiple devices specified different run_via_cron parameters, only one device's parameters would be applied to the resource.

class puppet_device::run::via_cron::untargeted {
  notify {"Warning: run_via_cron is not supported where 'puppet device' does not implement '--target'":}
}

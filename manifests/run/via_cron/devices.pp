# Conditional class.

# Perform a 'puppet device' run for all devices via cron.

# This class needs to be declared via include to prevent duplicate cron resources.
# But the parameters specified in the calling 'device' defined class are not in scope in this 'devices' class.
# And, if multiple devices specified different parameters, only the last device's parameters would be applied.
# So, this not supported.

class puppet_device::run::via_cron::devices {
  notify {'Warning: run_via_cron is not supported on this version of puppet':}
}

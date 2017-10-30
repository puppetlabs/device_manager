# Conditional class.

# Perform a 'puppet device' run via cron.
# This 'devices' class has to be called via include to prevent duplicate cron resources.
# But the variables defined in the calling 'device' class are not in scope in this class.

class puppet_device::run::via_cron::devices {

  # notify {'Warning: run_via_cron is not available for this version of Puppet':}

}

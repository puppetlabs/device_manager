# Conditional class.

# TODO: Remove '--user=root' after PUP-1391 is resolved.

# Perform a 'puppet device' run via cron.
# This 'devices' class has to be called via include to prevent duplicate cron resources.
# But the variables defined in the calling 'device' class are not in scope in this class.

class puppet_device::run::via_cron::devices {

  #notify {'Warning: run_via_cron is not available for this version of Puppet':}

  #cron {'run puppet_device via cron':
  #  ensure  => $puppet_device::run::via_cron::device::cron_ensure,
  #  command => "${puppet_device::run::command} device --user=root --waitforcert=0",
  #  user    => 'root',
  #  hour    => $puppet_device::run::via_cron::device::cron_hour,
  #  minute  => $puppet_device::run::via_cron::device::cron_minute,
  #}

}

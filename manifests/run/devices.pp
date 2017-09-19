# Conditional class.
# Remove '--user=root' after PUP-1391 is resolved.

class puppet_device::run::devices {

  exec {'run puppet_device':
    command => "${puppet_device::run::command} device --user=root --waitforcert=0",
    tag     => 'run_puppet_device',
  }

}

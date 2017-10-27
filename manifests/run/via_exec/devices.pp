# Conditional class.

# TODO: Remove '--user=root' after PUP-1391 is resolved.

# Perform a 'puppet device' run with every 'puppet agent' run.

class puppet_device::run::via_exec::devices {

  exec {'run puppet_device':
    command => "${puppet_device::run::command} device --user=root --waitforcert=0",
    tag     => 'run_puppet_device',
  }

}
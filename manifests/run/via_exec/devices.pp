# Conditional class.

# Perform a 'puppet device' run with every 'puppet agent' run.

class puppet_device::run::via_exec::devices {

  exec {'run puppet_device':
    command => "${puppet_device::run::command} --waitforcert=0",
    tag     => 'run_puppet_device',
  }

}
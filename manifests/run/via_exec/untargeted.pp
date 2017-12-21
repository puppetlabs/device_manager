# Perform a 'puppet device' run for all devices with every 'puppet agent' run.
# @api private

class puppet_device::run::via_exec::untargeted {

  exec {'run puppet_device':
    command => "${puppet_device::run::command} --waitforcert=0",
    tag     => 'run_puppet_device',
  }

}
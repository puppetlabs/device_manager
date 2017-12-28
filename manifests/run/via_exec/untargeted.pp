# Perform a 'puppet device' run for all devices with every 'puppet agent' run.
# @api private

# This class is declared via include to create just one Exec resource for all devices.

class puppet_device::run::via_exec::untargeted {

  exec {'run puppet_device':
    command => "\"${puppet_device::run::command}\" ${puppet_device::run::arguments}",
    tag     => 'run_puppet_device',
  }

}
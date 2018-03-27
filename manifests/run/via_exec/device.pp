# Perform a 'puppet device' run with every 'puppet agent' run.
# @api private

define puppet_device::run::via_exec::device {

  include puppet_device::run

  if $puppet_device::run::targetable {

    exec {"run puppet_device target ${name}":
      command => "\"${puppet_device::run::command}\" ${puppet_device::run::arguments} --target=${name}",
      require => Puppet_device::Conf::Device[$name],
      tag     => "run_puppet_device_${name}",
    }

  } else {

    # The following is included to create just one Exec resource for all devices.
    include puppet_device::run::via_exec::untargeted

  }

}
# Conditional class.
# Perform a 'puppet device' run with every 'puppet agent' run.

# TODO: Remove '--user=root' after PUP-1391 is resolved.

define puppet_device::run::device {

  include puppet_device::run

  if $puppet_device::run::targetable {

    exec {"run puppet_device target ${name}":
      command => "${puppet_device::run::command} device --target ${name} --user=root --waitforcert=0",
      require => Puppet_device::Conf::Device[$name],
      tag     => "run_puppet_device_${name}",
    }

  } else {

    include puppet_device::run::devices

  }

}

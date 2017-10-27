# Conditional class.

# TODO: Remove '--user=root' after PUP-1391 is resolved.

# Perform a 'puppet device' run via cron.

define puppet_device::run::via_cron::device {

  include puppet_device::run

  if $puppet_device::run::targetable {

    cron { "run puppet_device target ${name} via cron":
      ensure  => present,
      command => "${puppet_device::run::command} device --target ${name} --user=root --waitforcert=0",
      user    => 'root',
      hour    => absent,
      minute  => 45,
    }

  } else {

    include puppet_device::run::via_cron::devices

  }

}
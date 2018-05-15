# Perform a 'puppet device' run with every 'puppet agent' run.
# @api private

# The puppet command is quoted in this Exec to support spaces in the path on Windows.

define device_manager::run::via_exec::device {

  include device_manager::run

  if $device_manager::run::targetable {

    exec {"run device_manager target ${name}":
      command => "\"${device_manager::run::command}\" ${device_manager::run::arguments} --target=${name}",
      require => Device_manager::Conf::Device[$name],
      tag     => "run_device_manager_${name}",
    }

  } else {

    # The following is included to create just one Exec resource for all devices.
    include device_manager::run::via_exec::untargeted

  }

}

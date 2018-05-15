# Perform a 'puppet device' run for all devices with every 'puppet agent' run.
# @api private

# This class is declared via include to create just one Exec resource for all devices.

# The puppet command is quoted in this Exec to support spaces in the path on Windows.

class device_manager::run::via_exec::untargeted {

  exec {'run device_manager':
    command => "\"${device_manager::run::command}\" ${device_manager::run::arguments}",
    tag     => 'run_device_manager',
  }

}

# Perform a 'puppet device' run with every 'puppet agent' run.
# @api private

# The puppet command is quoted in this Exec to support spaces in the path on Windows.

define device_manager::run::via_exec::device (
  String  $run_user,
){

  include device_manager::run

  if $device_manager::run::targetable {

    if ($run_user == '') {
      $optional_user = ''
    } else {
      $optional_user = " --user=${run_user}"
    }

    exec { "run puppet device target ${name}":
      command => "\"${device_manager::run::command}\" ${device_manager::run::arguments} --target=${name}${optional_user}",
      require => Device_manager::Conf::Device[$name],
      tag     => "run_puppet_device_${name}",
    }

  } else {

    # The following is included to create just one Exec resource for all devices.
    include device_manager::run::via_exec::untargeted

  }

}

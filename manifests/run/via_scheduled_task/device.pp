# Perform a 'puppet device' run via a scheduled task.
# @api private

define device_manager::run::via_scheduled_task::device (
  String  $ensure,
  Integer $run_interval,
){

  include device_manager::run

  if (($ensure == present) and $run_interval > 0) {
    $scheduled_task_ensure = present
  } else {
    $scheduled_task_ensure = absent
  }

  if $device_manager::run::targetable {

    $random_minute = sprintf('%02d', fqdn_rand(59, $name))
    $start_time = "00:${$random_minute}"
    $task_name = regsubst($name, '\.', '_', 'G')

    scheduled_task { "run puppet device target ${task_name}":
      ensure    => $scheduled_task_ensure,
      command   => $device_manager::run::command,
      arguments => "${device_manager::run::arguments} --target=${name}",
      trigger   => {
        schedule         => 'daily',
        start_time       => $start_time,
        minutes_interval => $run_interval,
      }
    }

  } else {

    if (($ensure == present) and $run_interval > 0) {
      # The following is included to create just one resource for all devices.
      include device_manager::run::via_scheduled_task::untargeted
    }

  }

}

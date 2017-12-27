# Perform a 'puppet device' run via scheduled_task.
# @api private

define puppet_device::run::via_scheduled_task::device (
  String  $ensure,
  Boolean $run_via_scheduled_task,
  String  $run_via_scheduled_task_start_time,
  String  $run_via_scheduled_task_minutes_interval,
){

  include puppet_device::run

  if ($run_via_scheduled_task and ($ensure == present)) {
    $scheduled_task_ensure = present
  } else {
    $scheduled_task_ensure = absent
  }

  if $puppet_device::run::targetable {
    if ($facts['osfamily'] != 'windows') {
      notify {'Warning: run_via_scheduled_task is not supported on Linux':}
    } else {
      scheduled_task { "run puppet_device target ${name}":
        ensure    => present,
        command   => $puppet_device::run::command,
        arguments => "${puppet_device::run::arguments} --target ${name}",
        trigger   => {
          schedule         => 'daily',
          start_time       => $run_via_scheduled_task_start_time,
          minutes_interval => $run_via_scheduled_task_minutes_interval,
          minutes_duration => $run_via_scheduled_task_minutes_interval + 1,
        }
      }
    }
  } else {
    if ($run_via_scheduled_task and ($ensure == present)) {
      # The following is included to create just one Scheduled Task resource for all devices.
      include puppet_device::run::via_scheduled_task::untargeted
    }
  }

}
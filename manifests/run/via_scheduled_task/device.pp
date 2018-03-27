# Perform a 'puppet device' run via a scheduled task.
# @api private

define puppet_device::run::via_scheduled_task::device (
  String  $ensure,
  Integer $run_interval,
){

  include puppet_device::run

  if (($ensure == present) and $run_interval > 0) {
    $scheduled_task_ensure = present
  } else {
    $scheduled_task_ensure = absent
  }

  if $puppet_device::run::targetable {

    $random_minute = sprintf('%02d', fqdn_rand(59, $name))
    $start_time = "00:${$random_minute}"

    scheduled_task { "run puppet_device target ${name}":
      ensure    => $scheduled_task_ensure,
      command   => $puppet_device::run::command,
      arguments => "${puppet_device::run::arguments} --target=${name}",
      trigger   => {
        schedule         => 'daily',
        start_time       => $start_time,
        minutes_interval => $run_interval,
      }
    }

  } else {

    if (($ensure == present) and $run_interval > 0) {
      # The following is included to create just one resource for all devices.
      include puppet_device::run::via_scheduled_task::untargeted
    }

  }

}
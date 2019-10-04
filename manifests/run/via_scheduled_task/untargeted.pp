# Perform a 'puppet device' run for all devices via a scheduled task.
# @api private

# This class is declared via include to create just one Scheduled Task resource for all devices.

class device_manager::run::via_scheduled_task::untargeted {

  scheduled_task { 'run puppet device':
    ensure    => present,
    command   => $device_manager::run::command,
    arguments => $device_manager::run::arguments,
    trigger   => {
      schedule         => 'daily',
      start_time       => "00:${device_manager::run::random_minute}",
      minutes_interval => '60',
    }
  }

}

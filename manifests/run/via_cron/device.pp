# Perform a 'puppet device' run via cron.
# @api private

define puppet_device::run::via_cron::device (
  String  $ensure,
  Boolean $schedule_run,
){

  include puppet_device::run

  if (($ensure == present) and $schedule_run) {
    $cron_ensure = present
  } else {
    $cron_ensure = absent
  }

  if $puppet_device::run::targetable {

    $minute = sprintf('%02d', fqdn_rand(59, $name))

    cron { "run puppet_device target ${name}":
      ensure  => $cron_ensure,
      command => "${puppet_device::run::command} ${puppet_device::run::arguments} --target ${name}",
      user    => 'root',
      hour    => '*',
      minute  => $minute,
    }

  } else {

    if (($ensure == present) and $schedule_run) {
      # The following is included to create just one resource for all devices.
      include puppet_device::run::via_cron::untargeted
    }

  }

}
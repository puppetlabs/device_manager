# Perform a 'puppet device' run via cron.
# @api private

define puppet_device::run::via_cron::device (
  String  $ensure,
  Boolean $run_via_cron,
  String  $run_via_cron_hour,
  String  $run_via_cron_minute,
){

  include puppet_device::run

  if ($run_via_cron and ($ensure == present)) {
    $cron_ensure = present
  } else {
    $cron_ensure = absent
  }

  if $puppet_device::run::targetable {
    if ($facts['osfamily'] == 'windows') {
      notify {'Warning: run_via_cron is not supported on Windows':}
    } else {
      cron { "run puppet_device target ${name}":
        ensure  => $cron_ensure,
        command => "${puppet_device::run::command} ${puppet_device::run::arguments} --target ${name}",
        user    => 'root',
        hour    => $run_via_cron_hour,
        minute  => $run_via_cron_minute,
      }
    }
  } else {
    if ($run_via_cron and ($ensure == present)) {
      # The following is included to create just one Cron resource for all devices.
      include puppet_device::run::via_cron::untargeted
    }
  }

}
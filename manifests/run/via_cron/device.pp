# Conditional class.

# TODO: Remove '--user=root' after PUP-1391 is resolved.

# Perform a 'puppet device' run via cron.

define puppet_device::run::via_cron::device (
  String  $ensure,
  Boolean $run_via_cron,
  String  $run_via_cron_hour,
  String  $run_via_cron_minute,
){

  include puppet_device::run

  if ($run_via_cron and ($ensure == 'present')) {
    $cron_ensure = present
  } else {
    $cron_ensure = absent
  }

  if $run_via_cron_hour == '' {
    $cron_hour = absent
  } else {
    $cron_hour = $run_via_cron_hour
  }

  if $run_via_cron_minute == '' {
    $cron_minute = absent
  } else {
    $cron_minute = $run_via_cron_minute
  }

  if $puppet_device::run::targetable {

    cron { "run puppet_device target ${name} via cron":
      ensure  => $cron_ensure,
      command => "${puppet_device::run::command} device --target ${name} --user=root --waitforcert=0",
      user    => 'root',
      hour    => $cron_hour,
      minute  => $cron_minute,
    }

  } else {

    include puppet_device::run::via_cron::devices

  }

}

# Conditional class.

# Perform a 'puppet device' run via cron.

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

    cron { "run puppet_device target ${name} via cron":
      ensure  => $cron_ensure,
      command => "${puppet_device::run::command} --target ${name} --waitforcert=0",
      user    => 'root',
      hour    => $run_via_cron_hour,
      minute  => $run_via_cron_minute,
    }

  } else {

    include puppet_device::run::via_cron::devices

  }

}
# Perform a 'puppet device' run via cron.
# @api private

define device_manager::run::via_cron::device (
  String  $ensure,
  Integer $run_interval,
  String  $run_user,
){

  include device_manager::run

  if (($ensure == present) and $run_interval > 0) {
    $cron_ensure = present
  } else {
    $cron_ensure = absent
  }

  if $device_manager::run::targetable {

    if ($run_interval == 0) {
      $hour   = absent
      $minute = absent
    } elsif ($run_interval == 1) {
      # Use '*' instead of generating a list of every minute in an hour.
      $hour   = '*'
      $minute = '*'
    } elsif ($run_interval <= 30) {
      # Generate a randomly offset list of interval minutes.
      $intervals = range(0, ((60 / $run_interval) - 1))
      $offset = fqdn_rand(min($run_interval, 59), $name)
      $hour   = '*'
      $minute = $intervals.map |$i| { ($i * $run_interval + $offset) }
    } elsif ($run_interval <= 60) {
      debug('rounding run_interval up to an hour, to accommodate cron syntax')
      $hour   = '*'
      $offset = fqdn_rand(min($run_interval, 59), $name)
      $minute = $offset
    } else {
      debug('rounding run_interval up to the nearest hour, to accommodate cron syntax')
      $offset = fqdn_rand(min($run_interval, 59), $name)
      $hour   = sprintf('*/%d', ceiling($run_interval / 60.0))
      $minute = $offset
    }

    # The above, via the interval_to_cron_time function:
    # $cron_time = device_manager::interval_to_cron_time($run_interval, fqdn_rand(max(1,min($run_interval, 59)), $name))

    if ($run_user == '') {
      $optional_user = ''
    } else {
      $optional_user = "--user=${run_user}"
    }

    cron { "run puppet device target ${name}":
      ensure  => $cron_ensure,
      command => "${device_manager::run::command} ${device_manager::run::arguments} --target=${name} ${optional_user}",
      user    => $::identity['user'],
      hour    => $hour,
      minute  => $minute,
      # hour     => $cron_time['hour'],
      # minute   => $cron_time['minute'],
    }

  } else {

    if (($ensure == present) and $run_interval > 0) {
      # The following is included to create just one resource for all devices.
      include device_manager::run::via_cron::untargeted
    }

  }

}

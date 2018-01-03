# Perform a 'puppet device' run via cron.
# @api private

define puppet_device::run::via_cron::device (
  String  $ensure,
  Integer $run_interval,
){

  include puppet_device::run

  if (($ensure == present) and $run_interval > 0) {
    $cron_ensure = present
  } else {
    $cron_ensure = absent
  }

  if $puppet_device::run::targetable {

    # The following Puppet code is the equivalent to the Ruby code in the
    # build_mcollective_metadata_cron_minute_array function for refresh-mcollective-metadata.
    #
    # $offset = fqdn_rand($interval)
    # $intervals = range(0, ((60 / $interval) - 1))
    # $minute = $intervals.map |$i| { $i * $interval + $offset }
    #
    # Both produce unexpected results when interval is greater than 30.
    # The following addresses that by rounding interval up to the next hour.
    # Doing so avoids impractical cron mathematics.

    if ($run_interval == 0) {
      $hour = '*'
      $minute = sprintf('%02d', fqdn_rand(59, $name))
    } elsif ($run_interval <= 30) {
      $intervals = range(0, ((60 / $run_interval) - 1))
      $offset = fqdn_rand($run_interval, $name)
      $hour = '*'
      $minute = $intervals.map |$i| { sprintf('%02d', $i * $run_interval + $offset) }
    } elsif ($run_interval <= 60) {
      # notify {'run_interval values greater than thirty minutes will be rounded up to the nearest hour':}
      $hour = '*'
      $minute = sprintf('%02d', fqdn_rand(59, $name))
    } else {
      # notify {'run_interval values greater than thirty minutes will be rounded up to the nearest hour':}
      $hour = sprintf('*/%02d', ceiling($run_interval / 60.0))
      $minute = fqdn_rand(59, $name)
    }

    cron { "run puppet_device target ${name}":
      ensure  => $cron_ensure,
      command => "${puppet_device::run::command} ${puppet_device::run::arguments} --target ${name}",
      user    => 'root',
      hour    => $hour,
      minute  => $minute,
    }

  } else {

    if (($ensure == present) and $run_interval > 0) {
      # The following is included to create just one resource for all devices.
      include puppet_device::run::via_cron::untargeted
    }

  }

}
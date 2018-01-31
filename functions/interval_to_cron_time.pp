function puppet_device::interval_to_cron_time (
  Integer[0,1440] $interval,
  Integer[0,59]   $offset,
) >> Hash {

  if ($interval == 0) {
    $hour   = absent
    $minute = absent
  } elsif ($interval == 1) {
    # Use '*' instead of generating a list of every minute in an hour.
    $hour   = '*'
    $minute = '*'
  } elsif ($interval <= 30) {
    # Generate an offset list of interval minutes.
    $intervals = range(0, ((60 / $interval) - 1))
    $hour   = '*'
    $minute = $intervals.map |$i| { ($i * $interval + $offset) }
  } elsif ($interval <= 60) {
    debug('rounding interval up to an hour, to accommodate cron syntax')
    $hour   = '*'
    $minute = $offset
  } else {
    debug('rounding interval up to the nearest hour, to accommodate cron syntax')
    $hour   = sprintf('*/%d', ceiling($interval / 60.0))
    $minute = $offset
  }

  $result = {
    hour   => $hour,
    minute => $minute,
  }

}
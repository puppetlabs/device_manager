# Manage device in device.conf.
# 
# @api private

define puppet_device::conf::device (
  String                    $type,
  String                    $url,
  Boolean                   $debug = false,
  Enum['present', 'absent'] $ensure = 'present',
) {

  include puppet_device::conf

  if ($ensure == 'present') {

    $debug_transport = $debug ? { true => "debug\n", default => '' }

    concat::fragment{ "puppet_device_conf [${name}]":
      target  => $puppet_device::conf::device_conf,
      content => "[${name}]\ntype ${type}\nurl ${url}\n${debug_transport}\n",
      order   => '99',
    }
  }

}

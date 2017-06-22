# Manage a device in device.conf.
# @api private

define puppet_device::conf::device (
  String                    $type,
  String                    $url,
  Boolean                   $debug = false,
  Enum['present', 'absent'] $ensure = 'present',
) {

  include puppet_device::conf

  if ($ensure == 'present') {

    if ($debug) {
      $debug_transport = 'debug'
    } else {
      $debug_transport = ''
    }

    concat::fragment{ "puppet_device_conf [${title}]":
      target  => $puppet_device::conf::device_conf,
      content => "[${title}]\ntype ${type}\nurl ${url}\n${debug_transport}\n",
      order   => '99',
    }
  }

}

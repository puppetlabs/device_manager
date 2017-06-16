# Manage a device in device.conf.
# @api private

define puppet_device::conf::device (
  String $type,
  String $url,
  Enum['present', 'absent'] $ensure = 'present',
) {
  include puppet_device::conf
  if ($ensure == 'present') {
    concat::fragment{ "puppet_device_conf [${title}]":
      target  => $puppet_device::conf::device_conf,
      content => "[${title}]\ntype ${type}\nurl ${url}\n\n",
      order   => '99',
    }
  }
}


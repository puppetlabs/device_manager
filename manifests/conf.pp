# Manage device.conf file.
# @api private

class puppet_device::conf {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $device_conf = $::puppet_deviceconfig

  concat { $device_conf:
    backup => false,
  }

  concat::fragment{ 'puppet_device_conf_comment':
    target  => $device_conf,
    content => "# This file is managed by the puppet_device module.\n\n",
    order   => '01',
  }
}

# Manage a device in device.conf.
# @api private

define puppet_device::conf::device (
  Enum['present', 'absent'] $ensure = 'present',
  String $type,
  String $url,
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

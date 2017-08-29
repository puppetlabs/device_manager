# Manage device.conf file.
# Using concat instead of inifile, because purgable.
# @api private

class puppet_device::conf {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $device_conf = $::puppet_deviceconfig

  concat { $device_conf:
    backup    => false,
    show_diff => false,
  }

  concat::fragment{ 'puppet_device_conf_comment':
    target  => $device_conf,
    content => "# This file is managed by the puppet_device module.\n\n",
    order   => '01',
  }
}

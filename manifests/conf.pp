# Manage the deviceconfig file.
# Using concat instead of inifile, because purgable.
# @api private

class device_manager::conf {

  if ($facts['os']['family'] != 'windows') {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }
  }

  # Use a fact to identify the confdir file on this agent.
  $devices_directory = "${::puppet_settings_confdir}/puppet/devices"

  file { $devices_directory:
    ensure => directory,
  }

  # Use a fact to identify the deviceconfig file on this agent.
  # Default: $confdir/device.conf

  $device_conf = $::puppet_settings_deviceconfig

  concat { $device_conf:
    backup    => false,
    show_diff => false,
  }

  concat::fragment{ 'device_manager_conf_comment':
    target  => $device_conf,
    content => "# This file is managed by the device_manager module.\n\n",
    order   => '01',
  }

}

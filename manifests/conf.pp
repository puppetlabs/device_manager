# Manage the deviceconfig file.
# Using concat instead of inifile, because purgable.
# @api private

class device_manager::conf {

  # Cannot pass parameters to included classes.
  $owner = lookup('device_manager::conf::owner', {'default_value' => $::identity['user']})
  $group = lookup('device_manager::conf::group', {'default_value' => $::identity['group']})

  # Use a fact to identify the confdir file on this agent.
  $devices_directory = "${::puppet_settings_confdir}/puppet/devices"

  file { $devices_directory:
    ensure       => directory,
    purge        => true,
    recurse      => true,
    recurselimit => 1,
  }

  # Use a fact to identify the deviceconfig file on this agent.
  # Default: $confdir/device.conf

  $device_conf_file = $::puppet_settings_deviceconfig

  concat { $device_conf_file:
    backup    => false,
    show_diff => false,
    owner     => $owner,
    group     => $group,
    mode      => '0640',
  }

  concat::fragment{ 'device_conf_comment':
    target  => $device_conf_file,
    content => "# This file is managed by the device_manager module.\n\n",
    order   => '01',
  }

}

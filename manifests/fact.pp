# Manage the devices structured fact.
# Structured as an array, but could be a hash.
# @api private

class device_manager::fact {

  # Use a fact to identify the confdir on this agent.

  ensure_resource('file', "${::puppet_settings_confdir}/facter", {'ensure' => 'directory'})
  ensure_resource('file', "${::puppet_settings_confdir}/facter/facts.d", {'ensure' => 'directory'})

  $devices_fact_file = "${::puppet_settings_confdir}/facter/facts.d/devices.yaml"

  concat { $devices_fact_file:
    backup         => false,
    ensure_newline => true,
  }

  concat::fragment{ 'devices_fact_header':
    target  => $devices_fact_file,
    content => '---',
    order   => '01',
  }

  concat::fragment{ 'devices_fact_comment':
    target  => $devices_fact_file,
    content => '# This file is managed by the device_manager module.',
    order   => '02',
  }

  concat::fragment{ 'devices_fact_name':
    target  => $devices_fact_file,
    content => 'devices:',
    order   => '03',
  }

}

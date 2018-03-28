# Manage the puppet_devices structured fact.
# Structured as an array, but could be a hash.
# @api private

class puppet_device::fact {

  # Use a fact to identify the confdir on this agent.

  ensure_resource('file', "${::puppet_settings_confdir}/facter", {'ensure' => 'directory'})
  ensure_resource('file', "${::puppet_settings_confdir}/facter/facts.d", {'ensure' => 'directory'})

  $puppet_devices = "${::puppet_settings_confdir}/facter/facts.d/puppet_devices.yaml"

  concat { $puppet_devices:
    backup         => false,
    ensure_newline => true,
  }

  concat::fragment{ 'puppet_devices_fact_header':
    target  => $puppet_devices,
    content => '---',
    order   => '01',
  }

  concat::fragment{ 'puppet_devices_fact_comment':
    target  => $puppet_devices,
    content => '# This file is managed by the puppet_device module.',
    order   => '02',
  }

  concat::fragment{ 'puppet_devices_fact_name':
    target  => $puppet_devices,
    content => 'puppet_devices:',
    order   => '03',
  }

}

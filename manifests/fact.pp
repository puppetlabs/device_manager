# Manage the device_managers structured fact.
# Structured as an array, but could be a hash.
# @api private

class device_manager::fact {

  # Use a fact to identify the confdir on this agent.

  ensure_resource('file', "${::puppet_settings_confdir}/facter", {'ensure' => 'directory'})
  ensure_resource('file', "${::puppet_settings_confdir}/facter/facts.d", {'ensure' => 'directory'})

  $device_managers = "${::puppet_settings_confdir}/facter/facts.d/device_managers.yaml"

  concat { $device_managers:
    backup         => false,
    ensure_newline => true,
  }

  concat::fragment{ 'device_managers_fact_header':
    target  => $device_managers,
    content => '---',
    order   => '01',
  }

  concat::fragment{ 'device_managers_fact_comment':
    target  => $device_managers,
    content => '# This file is managed by the device_manager module.',
    order   => '02',
  }

  concat::fragment{ 'device_managers_fact_name':
    target  => $device_managers,
    content => 'device_managers:',
    order   => '03',
  }

}

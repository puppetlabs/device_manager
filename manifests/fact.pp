# Manage puppet_devices structured fact.
# Structured as an array, but could be a hash.
# @api private

class puppet_device::fact {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { "${::puppetlabs_confdir}/facter":
    ensure => directory,
  }

  file { "${::puppetlabs_confdir}/facter/facts.d":
    ensure => directory,
  }

  $puppet_devices = "${::puppetlabs_confdir}/facter/facts.d/puppet_devices.yaml"

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

# Manage puppet_devices fact.
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

  $puppet_devices_yaml = "${::puppetlabs_confdir}/facter/facts.d/puppet_devices.yaml"

  concat { $puppet_devices_yaml:
    backup         => false,
    ensure_newline => true,
  }

  concat::fragment{ 'puppet_devices_yaml_header':
    target  => $puppet_devices_yaml,
    content => '---',
    order   => '01',
  }
  concat::fragment{ 'puppet_devices_yaml_comment':
    target  => $puppet_devices_yaml,
    content => '# This file is managed by the puppet_device module.',
    order   => '02',
  }
  concat::fragment{ 'puppet_devices_yaml_facts':
    target  => $puppet_devices_yaml,
    content => 'puppet_devices:',
    order   => '03',
  }

}

# Manage a fact for a device.
# @api private

define puppet_device::fact::device (
  Enum['present', 'absent'] $ensure = 'present',
) {
  include puppet_device::fact
  if ($ensure == 'present') {
    concat::fragment{ "puppet_devices_yaml_fact ${title}":
      target  => $puppet_device::fact::puppet_devices_yaml,
      content => "  - ${title}",
      order   => '99',
    }
  }
}

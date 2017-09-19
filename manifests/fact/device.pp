# Manage a fact for a device.
# @api private

define puppet_device::fact::device (
  Enum['present', 'absent'] $ensure = 'present',
) {

  include puppet_device::fact

  if ($ensure == 'present') {

    concat::fragment{ "puppet_devices_fact_value ${name}":
      target  => $puppet_device::fact::puppet_devices,
      content => "  ${name}: true",
      order   => '99',
    }

  }

}

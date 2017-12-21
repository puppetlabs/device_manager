# Manage this device in the puppet_devices fact.
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

  } else {

    # Do not define a concat::fragment for this device, ensuring 'absent'.

  }

}

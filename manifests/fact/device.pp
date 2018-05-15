# Manage this device in the device_managers fact.
# @api private

define device_manager::fact::device (
  Enum['present', 'absent'] $ensure = 'present',
) {

  include device_manager::fact

  if ($ensure == 'present') {

    concat::fragment{ "device_managers_fact_value ${name}":
      target  => $device_manager::fact::device_managers,
      content => "  ${name}: true",
      order   => '99',
    }

  } else {

    # Do not define a concat::fragment for this device, ensuring 'absent'.

  }

}

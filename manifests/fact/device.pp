# Manage this device in the devices fact.
# @api private

define device_manager::fact::device (
  Enum[present, absent] $ensure = present,
) {

  include device_manager::fact

  if ($ensure == present) {

    concat::fragment{ "devices_fact ${name}":
      target  => $device_manager::fact::devices_fact_file,
      content => "  ${name}: true",
      order   => '99',
    }

  } else {

    # Do not define a concat::fragment for this device, ensuring 'absent'.

  }

}

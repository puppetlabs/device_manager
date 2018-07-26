# if $key in $device vs if $device[$key]

function device_manager::value_or_default (
  String           $key,
  Hash             $device,
  Hash             $defaults,
  Optional[String] $device_type = undef
) {

  # If the key is specified in the device, return the device value.

  if $key in $device {
    return $device[$key]
  }

  # Otherwise, if a device type is specified,
  # and if the type is specified in the global defaults,
  # and if the key is specified in the type defaults, return the type value.

  if $device_type {
    if $device_type in $defaults {
      if $key in $defaults[$device_type] {
        return $defaults[$device_type][$key]
      }
    }
  }

  # Otherwise, if the key is specified in the global defaults, return the global value.

  if $key in $defaults {
    return $defaults[$key]
  }

  # Otherwise, the key is not specified in the device or the global or type defaults, return undef.

  return undef
}

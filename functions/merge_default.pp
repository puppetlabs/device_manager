# deep_merge: The key in the rightmost hash takes precedence.

function device_manager::merge_default (
  String           $key,
  Hash             $device,
  Hash             $defaults,
  Optional[String] $device_type = undef
) {

  # If a device type is specified,
  # and if the type is specified in the global defaults,
  # and if the key is specified in the type defaults, merge the global, type, and device values.

  if $device_type {
    if $device_type in $defaults {
      if $key in $defaults[$device_type] {
        $defaults_and_type_defaults = deep_merge($defaults[$key], $defaults[$device_type][$key])
        return deep_merge($defaults_and_type_defaults, $device[$key])
      }
    }
  }

  # Otherwise, if the key is specified in the global defaults, merge the global and device values.

  if $key in $defaults {
    return deep_merge($defaults[$key], $device[$key])
  }

  # Otherwise, if the key is specified in the defaults, return the device value.

  return $device[$key]
}

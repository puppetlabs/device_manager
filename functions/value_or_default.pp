function device_manager::value_or_default (
  String           $attribute,
  Hash             $resource_parameters,
  Hash             $defaults,
  Optional[String] $device_type = undef
) {

  # If the attribute is specified in the resource parameters, return it.
  if $resource_parameters[$attribute] {
    return $resource_parameters[$attribute]
  }

  # Otherwise, if a device type is provided ...
  if $device_type {
    # ... and if the type has defaults that are specified in the defaults ...
    if $defaults[$device_type] {
      # ... and if the attribute is specified in the defaults for the type, return it.
      if $defaults[$device_type][$attribute] {
        return $defaults[$device_type][$attribute]
      }
    }
  }

  # Otherwise, if the attribute is specified in the defaults, return it.
  if $defaults[$attribute] {
    return $defaults[$attribute]
  }

}

# TODO: Is has_key() faster or safer?

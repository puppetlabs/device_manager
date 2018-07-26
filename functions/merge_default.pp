function device_manager::merge_default (
  String           $attribute,
  Hash             $resource_parameters,
  Hash             $defaults,
  Optional[String] $device_type = undef
) {

  # If the attribute is specified in the resource parameters, merge and return it.
  if $resource_parameters[$attribute] {
    return deep_merge($defaults[$attribute], $resource_parameters[$attribute])
  }

  # Otherwise, if a device type is provided ...
  if $device_type {
    # ... and if the type has defaults that are specified in the defaults ...
    if $defaults[$device_type] {
      # ... and if the attribute is specified in the defaults for the type, merge and return it.
      if $defaults[$device_type][$attribute] {
        return deep_merge($defaults[$device_type][$attribute], $resource_parameters[$attribute])
      }
    }
  }

  # Otherwise, if the attribute is specified in the defaults, return it.
  if $defaults[$attribute] {
    return $defaults[$attribute]
  }

}

# TODO: Is has_key() faster or safer?
# TODO: Perform a multiple-layer merge?

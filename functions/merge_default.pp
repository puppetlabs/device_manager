function device_manager::merge_default($name, $parameters, $defaults) {
  if $parameters[$name] { deep_merge($defaults[$name], $parameters[$name]) } else { $defaults[$name] }
}

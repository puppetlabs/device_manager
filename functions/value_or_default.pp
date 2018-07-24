function device_manager::value_or_default($name, $parameters, $defaults) {
  if $parameters[$name] { $parameters[$name] } else { $defaults[$name] }
}

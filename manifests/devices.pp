# Read all devices from Hiera.

class puppet_device::devices {
  $devices = lookup('puppet_device::devices', Hash, 'hash', {})
  create_resources(puppet_device, $devices)
}

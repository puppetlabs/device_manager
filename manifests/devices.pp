# Read all devices from Hiera.

class puppet_device::devices {
# $devices = lookup('puppet_device::devices', Hash, 'hash', {})
  $devices = hiera_hash('puppet_device::devices', {})

# create_resources(puppet_device, $devices)
  $devices.each |$title, $device| {
    puppet_device {$title:
      name  => $device['name'],
      type  => $device['type'],
      url   => $device['url'],
      debug => $device['debug'],
      run   => $device['run'],
    }
  }
}
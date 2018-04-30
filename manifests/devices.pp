# puppet_device::devices
#
# Configure multiple devices through data.
# Use either the `$devices` parameter to pass in data through the Classifier,
# or set the `puppet_device::devices` key in Hiera.
# If configuration for the same device is specified in both,
# the `$devices` parameter wins.
#
# @summary Configure multiple devices through data.
#
# @example in Hiera:
#   ---
#   puppet_device::devices:
#     bigip1.example.com:
#       type:         'f5'
#       url:          'https://admin:fffff55555@10.0.1.245/'
#       run_interval: 30
#     bigip2.example.com:
#       type:         'f5'
#       url:          'https://admin:fffff55555@10.0.2.245/'
#       run_interval: 30
#
# @example The datastructure to pass through the Classifier is exactly the same:
#   class { 'puppet_device::devices':
#     devices => {
#       'bigip1.example.com' => {
#         type => 'f5',
#         url  => 'https://admin:fffff55555@10.0.1.245/',
#         run_interval => 30,
#       },
#       'bigip2.example.com' => {
#         type => 'f5',
#         url  => 'https://admin:fffff55555@10.0.1.245/',
#         run_interval => 30,
#       },
#     }
#   }
class puppet_device::devices(Hash $devices = {}) {

  # Validate node.

  unless has_key($facts, 'aio_agent_version') {
    fail("Classification Error: 'puppet_device::devices' declared on a device instead of an agent.")
  }

  # Avoid the Hiera 5 'hiera_hash is deprecated' warning.

  if ( (versioncmp($::clientversion, '4.9.0') >= 0) and (! defined('$::serverversion') or versioncmp($::serverversion, '4.9.0') >= 0) ) {
    $hiera_devices = lookup('puppet_device::devices', Hash, 'hash', {})
  } else {
    $hiera_devices = hiera_hash('puppet_device::devices', {})
  }

  ($hiera_devices + $devices).each |$title, $device| {
    puppet_device {$title:
      name         => $device['name'],
      type         => $device['type'],
      url          => $device['url'],
      debug        => $device['debug'],
      run_interval => $device['run_interval'],
      run_via_exec => $device['run_via_exec'],
    }
  }

}

# Manage this device in the device.conf file.
# Using concat instead of inifile, because purgable.
# @api private

define puppet_device::conf::device (
  String                    $type,
  String                    $url,
  Hash                      $credentials,
  Boolean                   $debug = false,
  Enum['present', 'absent'] $ensure = 'present',
) {

  include puppet_device::conf

  $credentials_file = "${puppet_device::conf::devices_directory}/${name}.yaml"

  if ($ensure == 'present') {

    # Either the credentials are in the url,
    # or define the credentials in a HOCON file and set the url to that file.

    if (empty($credentials)) {
      $url_url = $url
    } else {
      $url_url = "file://${credentials_file}"
      file { $credentials_file:
        ensure => file,
      }
      $credentials.each |$key, $value| {
        hocon_setting { "${name}_${key}":
          ensure  => present,
          path    => $credentials_file,
          setting => "default.node.${key}",
          value   => $value,
        }
      }
    }

    $debug_transport = $debug ? { true => "debug\n", default => '' }

    concat::fragment{ "puppet_device_conf [${name}]":
      target  => $puppet_device::conf::device_conf,
      content => "[${name}]\ntype ${type}\nurl ${url_url}\n${debug_transport}\n",
      order   => '99',
      tag     => "device_${name}",
    }

  } else {

    file { $credentials_file:
      ensure => absent,
    }

    # Do not define a concat::fragment for this device, ensuring 'absent'.

  }

}

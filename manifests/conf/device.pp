# Manage this device in the device.conf file.
# Using concat instead of inifile, because purgable.
# @api private

define device_manager::conf::device (
  String                    $type,
  String                    $url,
  Hash                      $credentials,
  Boolean                   $debug = false,
  Enum[present, absent]     $ensure = present,
) {

  include device_manager::conf

  $credentials_file = "${device_manager::conf::devices_directory}/${name}.conf"

  if ($ensure == present) {

    # Either the credentials are in the url,
    # or define the credentials in a HOCON file and set the url to that file.

    if (empty($credentials)) {
      $url_value = $url
    } else {
      $url_value = "file://${credentials_file}"
      $credentials_json = to_json_pretty($credentials)

      file { $credentials_file:
        ensure  => file,
        content => $credentials_json,
      }

    }

    $debug_value = $debug ? { true => "debug\n", default => '' }

    concat::fragment{ "device_conf ${name}":
      target  => $device_manager::conf::device_conf_file,
      content => "[${name}]\ntype ${type}\nurl ${url_value}\n${debug_value}\n",
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

# puppet_device

#### Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Orchestration](#orchestration)
1. [Reference](#reference)

## Description

Devices require a (proxy) Puppet agent to request certificates, collect facts, retrieve and apply catalogs, and store reports.

This module manages the configuration of devices used by `puppet device` on Puppet agents.

This module also provides the potential for (indirect) orchestration of `puppet device` runs.

## Usage

Install the `puppet_device` module:

~~~
puppet module install tkishel-puppet_device
~~~

Declare individual `puppet_device` resources in a manifest:

~~~
puppet_device {'bigip.example.com':
  type   => 'f5',
  url    => 'https://admin:fffff55555@10.0.0.245/',
}
~~~

Or declare multiple `puppet_device` resources in Hiera ...

~~~
---
puppet_device::devices:
  bigip1.example.com:
    type: 'f5'
    url:  'https://admin:fffff55555@10.0.1.245/'
  bigip2.example.com:
    type: 'f5'
    url:  'https://admin:fffff55555@10.0.2.245/'
~~~

... and declare the `puppet_device::devices` class:

~~~
include puppet_device::devices
~~~

Note that an f5 device is used as an example: but this module is not limited to F5 devices.

## Parameters

### name

Data type: String

Specifies the `certname` of the device.

This parameter is optional, and defaults to the title of the resource.

### ensure

Data type: String

This parameter is optional, with valid options of: 'present' (the default) and 'absent'.

Setting to 'absent' deletes the device from `device.conf` and the `puppet_devices` fact, and negates the effect of any other parameters.

### type

Data type: String

Specifies the type of the device.

### url

Data type: String

Specifies the URL used to configure the device.

### debug

Data type: Boolean

This parameter is optional, with a default of false.

Specifies transport-level debug output for the device, and is limited to telnet and ssh transports.

### run

Data type: Boolean

This parameter is optional, with a default of false.

Specifies whether to run `puppet device` during each `puppet agent` run on the Puppet agent.

Setting to true will create one Exec resource for all devices on the Puppet agent.

## Orchestration

If `puppet device --target` is available (Puppet 5.x) on the Puppet agent, setting `run` to true will create an Exec resource for each device (tagged with `run_puppet_device_${name}`) which can be combined with Orchestration (via a PQL query) to orchestrate a `puppet device` run on the Puppet agent for a device.

For example:

~~~
puppet job run --query 'resources[certname] { tag = "run_puppet_device_bigip.example.com"}'
~~~

## Reference

For more information about devices, see:

https://docs.puppet.com/puppet/latest/man/device.html

https://docs.puppet.com/puppet/latest/config_file_device.html

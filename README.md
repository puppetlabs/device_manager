# puppet_device

#### Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Tasks](#tasks)
1. [Reference](#reference)

## Description

Devices require a (proxy) Puppet agent to request certificates, collect facts, retrieve and apply catalogs, and store reports.

This module ...

* Manages the configuration of devices (in device.conf) used by the `puppet device` command on Puppet agents.

* Provides a `puppet_device` task for orchestration of `puppet device` runs on Puppet agents, via the `puppet task` command.

* Provides (via the `autorun` parameter) indirect orchestration of `puppet device` runs on Puppet agents, via the `puppet job` command.

## Usage

Install the `puppet_device` module:

~~~
puppet module install tkishel-puppet_device
~~~

Declare individual `puppet_device` resources in a manifest:

~~~
node 'agent.example.com' {
  class {'f5': }

  puppet_device {'bigip.example.com':
    type   => 'f5',
    url    => 'https://admin:fffff55555@10.0.0.245/',
  }
}
~~~

Or, declare multiple `puppet_device` resources in Hiera ...

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
node 'agent.example.com'  {
  class {'f5': }

  include puppet_device::devices
}
~~~

(Note that an f5 device is used as an example, but this module is not limited to F5 devices.)

## Parameters

### name

Data type: String

Specifies the `certname` of the device.

This parameter is optional, and defaults to the title of the resource.

### ensure

Data type: String

This parameter is optional, with valid options of 'present' (the default) and 'absent'.

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

### autorun

Data type: Boolean

This parameter is optional, with a default of false.

Specifies whether to automatically run `puppet device` during each `puppet agent` run on the Puppet agent.

Setting `autorun` to true will create an Exec resource for all devices on the Puppet agent. On versions of Puppet (Puppet 5.x or higher) that support `puppet device --target`, setting `autorun` to true will create an Exec resource for each device on the Puppet agent.

[comment]: # (This will increase the execution time of a puppet agent run by the execution time of a puppet device run.)

##### autorun and indirect orchestration

With `autorun` set to true, to explicitly orchestrate a run of `puppet device` (via `puppet agent`) on the Puppet agent:

~~~
puppet job run --nodes 'agent.example.com'
~~~

With `autorun` set to true, to query PuppetDB to orchestrate a run of `puppet device` (via `puppet agent`) on the Puppet agent:

~~~
puppet job run --query 'inventory { facts.puppet_devices."bigip.example.com" = true }'
~~~

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "run_puppet_device_bigip.example.com"}')

## Tasks

On versions of Puppet Enterprise (2017.3.x or higher) that support tasks, this module provides a `puppet_device` task which can be used with the `puppet task` command to orchestrate a `puppet device` run on the Puppet agent. This task does not require `autorun` set to true.

To explicitly orchestrate a run of the `puppet device` command on the Puppet agent:

~~~
puppet task run puppet_device --nodes 'agent.example.com'
~~~

To query PuppetDB to orchestrate a run of the `puppet device` command on the Puppet agent:

~~~
puppet task run puppet_device --query 'inventory { facts.puppet_devices."bigip.example.com" = true }'
~~~

To query PuppetDB to orchestrate a run of the `puppet device --target` command on the Puppet agent:

~~~
puppet task run puppet_device --query 'inventory { facts.puppet_devices."bigip.example.com" = true }' target=bigip.example.com
~~~

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "device_bigip.example.com"}')

For help with the `puppet_device` task, run the `puppet task show puppet_device` command.

## Reference

For more information about devices, see:

https://docs.puppet.com/puppet/latest/man/device.html

https://docs.puppet.com/puppet/latest/config_file_device.html

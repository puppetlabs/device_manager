# puppet_device

#### Table of Contents

1. [Description](#description)
1. [What does this module provide?](#what-does-this-module-provide)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Orchestration](#orchestration)
1. [Reference](#reference)

## Description

Devices require a (proxy) Puppet agent to request certificates, collect facts, retrieve and apply catalogs, and store reports.
This module manages the configuration file used by the `puppet device` command on those Puppet agents, and provides additional resources for managing `puppet device` runs.

## What does this module provide?

1. Allows for the configuration of `device.conf` in a manifest or Hiera.
1. Provides an option for scheduling of `puppet device` runs.
1. Provides an optional task for direct orchestration of `puppet device` runs on newer Puppet agents.
1. Provides an option for indirect orchestration of `puppet device` runs on older Puppet agents.
1. Defines a structured fact that can be used to query PuppetDB to identify the Puppet agent proxying for a device.

## Usage

Install the `puppet_device` module:

~~~
puppet module install tkishel-puppet_device
~~~

Declare individual `puppet_device` resources in a manifest of a Puppet agent:

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

### run_via_cron (beta)

Data type: Boolean

This parameter is optional, with a default of false.

Setting `run_via_cron` to true will create a Cron resource for the device that executes `puppet device --target` on the Puppet agent.

When this parameter is set to true, either `run_via_cron_hour` or `run_via_cron_minute` must be specified.

### run_via_cron_hour (beta)

Data type: String

This parameter is optional, without a default, and not specifying it is equivalent to `hour => absent`.

Specifies the hour attribute of the Cron resource created by `run_via_cron`.

### run_via_cron_minute (beta)

Data type: String

This parameter is optional, without a default, and not specifying it is equivalent to `minute => absent`.

Specifies the minute attribute of the Cron resource created by `run_via_cron`.

### run_via_exec

Data type: Boolean

This parameter is optional, with a default of false.

Specifies whether to automatically run `puppet device` during each `puppet agent` run on the Puppet agent.

Setting `run_via_exec` to true will create an Exec resource for the device that executes `puppet device --target` on the Puppet agent.
On versions of Puppet (lower than Puppet 5.x.x) that do not support `puppet device --target`, setting `run_via_exec` to true will instead create one Exec resource that executes `puppet device` for all devices on the Puppet agent.

Note that this will increase the execution time of a `puppet agent` run by the execution time of each `puppet device` run.

## Orchestration

### Puppet Task

On versions of Puppet Enterprise (2017.3.x or higher) that support tasks,
this module provides a `puppet_device` task which can be used by the `puppet task` command
to orchestrate a `puppet device` run on a (proxy) Puppet agent.

To orchestrate a run of the `puppet device` command, for all devices on a specified Puppet agent:

~~~
puppet task run puppet_device --nodes 'agent.example.com'
~~~

To orchestrate a run of the `puppet device` command, for all devices on a Puppet agent identified by a PuppetDB query:

~~~
puppet task run puppet_device --query 'inventory { facts.puppet_devices."bigip.example.com" = true }'
~~~

To orchestrate a run of the `puppet device --target` command, for a specific device on a Puppet agent identified by a PuppetDB query:

~~~
puppet task run puppet_device --query 'inventory { facts.puppet_devices."bigip.example.com" = true }' target=bigip.example.com
~~~

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "device_bigip.example.com"}')

For help with the `puppet_device` task, run the `puppet task show puppet_device` command.

### Puppet Job

On versions of Puppet Enterprise (2017.2.x or lower) that do not support tasks,
this module provides an `run_via_exec` parameter which can be used by the `puppet job` command
to indirectly orchestrate a `puppet device` run via a `puppet agent` run on the (proxy) Puppet agent.

To orchestrate a run of the `puppet device` command (for each device with `run_via_exec` set to true) on a specified Puppet agent:

~~~
puppet job run --nodes 'agent.example.com'
~~~

To orchestrate a run of the `puppet device` command (for each device with `run_via_exec` set to true) on a Puppet agent identified by a PuppetDB query:

~~~
puppet job run --query 'inventory { facts.puppet_devices."bigip.example.com" = true }'
~~~

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "run_puppet_device_bigip.example.com"}')

## Reference

For more information, see:

https://docs.puppet.com/puppet/latest/man/device.html

https://docs.puppet.com/puppet/latest/config_file_device.html

https://puppet.com/docs/pe/latest/orchestrator/running_tasks.html

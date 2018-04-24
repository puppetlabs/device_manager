# puppet_device

#### Table of Contents

1. [Description](#description)
1. [What does this module provide?](#what-does-this-module-provide)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Orchestration](#orchestration)
1. [Reference](#reference)

## Description

Devices require a proxy Puppet agent to request certificates, collect facts, retrieve and apply catalogs, and store reports. This module manages the configuration file used by the `puppet device` command and provides additional resources for scheduling and orchestrating `puppet device` runs on those proxy Puppet agents.

## What does this module provide?

* Allows for the configuration of `device.conf` in a manifest or in Hiera.
* Provides an option for scheduling of `puppet device` runs on proxy Puppet agents.
* Provides an optional task for direct orchestration of `puppet device` runs on newer proxy Puppet agents.
* Provides an option for indirect orchestration of `puppet device` runs on older proxy Puppet agents.
* Defines a structured fact that can be used to query PuppetDB to identify the Puppet agent proxying for a device.

## Usage

Install the `puppet_device` module:

```bash
puppet module install tkishel-puppet_device
```

Declare individual `puppet_device` resources in a manifest applied to the proxy Puppet agent:

```puppet
node 'agent.example.com' {
  class {'f5': }
  puppet_device {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.0.245/',
    run_interval => 30,
  }
}
```

Or, declare multiple `puppet_device` resources in Hiera ...

```yaml
---
puppet_device::devices:
  bigip1.example.com:
    type:         'f5'
    url:          'https://admin:fffff55555@10.0.1.245/'
    run_interval: 30
  bigip2.example.com:
    type:         'f5'
    url:          'https://admin:fffff55555@10.0.2.245/'
    run_interval: 30
```

... and declare the `puppet_device::devices` class in a manifest applied to the proxy Puppet agent:

```puppet
node 'agent.example.com'  {
  class {'f5': }
  include puppet_device::devices
}
```

Declaring either will configure `device.conf` on the proxy Puppet agent, allowing it to execute `puppet device` runs on behalf of its configured devices:

```bash
puppet device --user=root --verbose --target bigip.example.com
```

Note: While f5 devices are used in these examples, this module is not limited to F5 devices.

## Parameters

### name

Data type: String

This parameter is optional, and defaults to the title of the resource.

Specifies the `certname` of the device.

### ensure

Data type: String

This parameter is optional, with valid options of 'present' (the default) and 'absent'.

Setting to 'absent' deletes the device from `device.conf` and the `puppet_devices` fact, and negates the effect of any other parameters.

### type

Data type: String

Specifies the type of the device in `device.conf` on the proxy Puppet agent.

### url

Data type: String

Specifies the URL of the device in `device.conf` on the proxy Puppet agent.

### debug

Data type: Boolean

This parameter is optional, with a default of false.

Specifies transport-level debugging of the device in `device.conf` on the proxy Puppet agent, and is limited to debugging the telnet and ssh transports.

Note: This parameter specifies the `debug` property defined in: [Config Files: device.conf](https://puppet.com/docs/puppet/latest/config_file_device.html) rather than the `--debug` option defined in: [Man Page: puppet device](https://puppet.com/docs/puppet/latest/man/device.html).

### run_interval

Data type: Integer

This parameter is optional, with a default of 0.

Setting `run_interval` to a value between 1 and 1440 will create a Cron (or on Windows, a Scheduled Task) resource for the device that executes `puppet device --target` every `run_interval` minutes (with a randomized offset) on the proxy Puppet agent. When creating a Cron resource, values greater than thirty minutes will be rounded up to the nearest hour.

[comment]: # (Doing so avoids impractical cron mathematics.)

```puppet
puppet_device {'bigip.example.com':
  type                => 'f5',
  url                 => 'https://admin:fffff55555@10.0.0.245/',
  run_interval        => 30,
}
```

Note: On versions of Puppet (lower than Puppet 5.x.x) that do not support `puppet device --target`, this parameter will instead create one Cron (or Scheduled Task) resource that executes `puppet device` for all devices in `device.conf` every 60 minutes (at a randomized minute) on the proxy Puppet agent.

### run_via_exec (deprecated)

Data type: Boolean

This parameter is optional, with a default of false.

Setting `run_via_exec` to true will create an Exec resource for the device that executes `puppet device --target` during each `puppet agent` on the proxy Puppet agent. This parameter is deprecated in favor of `run_interval`, as `run_via_exec` will increase the execution time of a `puppet agent` run by the execution time of each `puppet device` run.

```puppet
puppet_device {'bigip.example.com':
  type         => 'f5',
  url          => 'https://admin:fffff55555@10.0.0.245/',
  run_via_exec => true,
}
```

Note: On versions of Puppet (lower than Puppet 5.x.x) that do not support `puppet device --target`, this parameter will instead create one Exec resource that executes `puppet device` for all devices in `device.conf`.

## Orchestration

### Puppet Tasks

On versions of Puppet Enterprise (2017.3.x or higher) that support Puppet Tasks, this module provides a `puppet_device` task which can be used by the `puppet task` command to orchestrate a `puppet device` run on the proxy Puppet agent. Help for this task is available via: `puppet task show puppet_device` command.

#### Examples:

To run `puppet device` for all devices in `device.conf` on the specified proxy Puppet agent:

```bash
puppet task run puppet_device --nodes 'agent.example.com'
```

To run `puppet device` for all devices in `device.conf` on the proxy Puppet agent identified by a PuppetDB query:

```bash
puppet task run puppet_device --query 'inventory { facts.puppet_devices."bigip.example.com" = true }'
```

To run `puppet device --target` for a specific device in `device.conf` on the proxy Puppet agent identified by a PuppetDB query:

```bash
puppet task run puppet_device --query 'inventory { facts.puppet_devices."bigip.example.com" = true }' target=bigip.example.com
```

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "device_bigip.example.com"}')

### Puppet Job (deprecated)

On versions of Puppet Enterprise (2017.2.x or lower) that do not support Puppet Tasks, this module provides an `run_via_exec` parameter which can be used by the `puppet job` command to indirectly orchestrate a `puppet device` run via an orchestrated `puppet agent` run on the proxy Puppet agent.

#### Examples:

To run `puppet device` for each device with `run_via_exec` set to true on the specified proxy Puppet agent:

```
puppet job run --nodes 'agent.example.com'
```

To run `puppet device` for each device with `run_via_exec` set to true on the proxy Puppet agent identified by a PuppetDB query:

```bash
puppet job run --query 'inventory { facts.puppet_devices."bigip.example.com" = true }'
```

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "run_puppet_device_bigip.example.com"}')

## Reference

For more information, see:

* [Man Page: puppet device](https://puppet.com/docs/puppet/latest/man/device.html)
* [Config Files: device.conf](https://puppet.com/docs/puppet/latest/config_file_device.html)
* [Running Tasks](https://puppet.com/docs/pe/latest/orchestrator/running_tasks.html)

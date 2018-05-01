# puppet_device

#### Table of Contents

1. [Description](#description)
1. [What does this module provide?](#what-does-this-module-provide)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Orchestration](#orchestration)
1. [Reference](#reference)

## Description

Devices require a proxy Puppet agent to request certificates, collect facts, retrieve and apply catalogs, and store reports. This module manages the configuration file used by the `puppet device` command, applies the base class of associated device modules, and provides additional resources for scheduling and orchestrating `puppet device` runs on those proxy Puppet agents.

## What does this module provide?

* Allows for the configuration devices in `device.conf` via a manifest, the Classifier, and/or Hiera.
* Provides an option for scheduling of `puppet device` runs on proxy Puppet agents.
* Provides an optional task for direct orchestration of `puppet device` runs on newer proxy Puppet agents.
* Provides an option for indirect orchestration of `puppet device` runs on older proxy Puppet agents.
* Defines a structured fact that can be used to query PuppetDB to identify the Puppet agent proxying for a device.
* Applies the base class of associated device modules to the proxy Puppet agent.

## Usage

### Install

On the master(s), install the `puppet_device` module:

```bash
puppet module install tkishel-puppet_device
```

Also, install the device-specific module on the master(s):

```bash
puppet module install f5-f5
```

### Configure

Devices can be declared either individually via a manifest, or multiple devices can be declared via the Classifier and/or Hiera.

Note: If the same device (identified by name) is declared via the Classifier and Hiera, the Classifier will take precedence.

#### Declare Individual Resources via a Manifest:

Declare individual `puppet_device` resources via a manifest applied to the proxy Puppet agent:

```puppet
node 'agent.example.com' {
  puppet_device {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.0.245/',
    run_interval => 30,
  }
}
```

#### Declare Multiple Resources via the Classifier:

Declare multiple `puppet_device` resources via the `devices` parameter to the `puppet_device::devices` class applied to the proxy Puppet agent via the Classifier:

```puppet
{
  'bigip1.example.com' => {
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.1.245/',
    run_interval => 30,
  },
  'bigip2.example.com' => {
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.1.245/',
    run_interval => 30,
  },
}
```

Also, apply the class of the device-specific module to the proxy Puppet agent via the Classifier.

#### Declare Multiple Resources via Hiera:

Declare multiple `puppet_device` resources via the `puppet_device::devices` key applied to the proxy Puppet agent via Hiera:

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
  include puppet_device::devices
}
```

### Run `puppet device`

Declaring these resources will configure `device.conf` and apply the base class of device modules on the proxy Puppet agent, allowing it to execute `puppet device` runs on behalf of its configured devices:

```bash
puppet device --user=root --verbose --target bigip.example.com
```

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

### credentials

Data type: Hash

This parameter is specific to devices that use the Puppet Resource API.

Specifies the credentials of the device in a HOCON file in `confdir/devices`, and sets that file as the URL of the device in `device.conf`, on the proxy Puppet agent.

```puppet
puppet_device {'cisco2600.example.com':
  type        => 'cisco_ios',
  credentials => {
                  address         => '10.0.1.245',
                  port            => 22,
                  username        => 'admin',
                  password        => 'cisco2600',
                  enable_password => 'cisco2600',
  },
}
```

### debug

Data type: Boolean

This parameter is optional, with a default of false.

Specifies transport-level debugging of the device in `device.conf` on the proxy Puppet agent, and is limited to debugging the telnet and ssh transports.

Note: This parameter specifies the `debug` property defined in: [Config Files: device.conf](https://puppet.com/docs/puppet/latest/config_file_device.html) rather than the `--debug` option defined in: [Man Page: puppet device](https://puppet.com/docs/puppet/latest/man/device.html).

### include_module

Data type: Boolean, with a default of true.

Specifies automatically including the base class (if one is defined) of the associated device module specified by the `type` parameter, on the proxy Puppet agent.

Device modules often implement a base class that applies an `install` class. Automatically including that class will automatically install any requirements of the device module.

### run_interval

Data type: Integer

This parameter is optional, with a default of 0.

Setting `run_interval` to a value between 1 and 1440 will create a Cron (or on Windows, a Scheduled Task) resource for the device that executes `puppet device --target` every `run_interval` minutes (with a randomized offset) on the proxy Puppet agent. When creating a Cron resource, values greater than thirty minutes will be rounded up to the nearest hour.

[comment]: # (Doing so avoids impractical cron mathematics.)

```puppet
puppet_device {'bigip.example.com':
  type         => 'f5',
  url          => 'https://admin:fffff55555@10.0.0.245/',
  run_interval => 30,
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

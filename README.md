# device_manager

#### Table of Contents

1. [Description](#description)
1. [What does this module provide?](#what-does-this-module-provide)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Orchestration](#orchestration)
1. [Reference](#reference)

## Description

Devices require a proxy Puppet agent to request certificates, collect facts, retrieve and apply catalogs, and store reports. This module manages the configuration files used by the `puppet device` command, applies the base class of associated device modules, and provides additional resources for scheduling and orchestrating `puppet device` runs on those proxy Puppet agents.

## What does this module provide?

* Allows for the configuration of devices in `device.conf` via a manifest, the Classifier, and/or Hiera.
* Provides an option for scheduling of `puppet device` runs on proxy Puppet agents.
* Provides an optional task for direct orchestration of `puppet device` runs on newer proxy Puppet agents.
* Provides an option for indirect orchestration of `puppet device` runs on older proxy Puppet agents.
* Defines a structured fact that can be used to query PuppetDB to identify the Puppet agent proxying for a device.
* Applies the base class of associated device modules to the proxy Puppet agent.

## Usage

### Install

On the master(s), install the `device_manager` module:

```bash
puppet module install puppetlabs-device_manager
```

Also, install the device-specific module on the master(s):

```bash
puppet module install f5-f5
```

### Configure

Devices can be declared either individually via a manifest, or multiple devices can be declared via the Classifier and/or Hiera.

Note: If the same device (identified by name) is declared via the Classifier and Hiera, the Classifier will take precedence.

#### Manage Individual Devices via a Manifest:

Declare individual `device_manager` resources via a manifest applied to the proxy Puppet agent:

```puppet
node 'agent.example.com' {
  device_manager {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.0.245/',
    run_interval => 30,
  }
}
```

#### Manage Multiple Devices via the Classifier:

Declare multiple `device_manager` resources via the `devices` parameter to the `device_manager::devices` class applied to the proxy Puppet agent via the Classifier:

```puppet
{
  'bigip1.example.com' => {
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.1.245/',
    run_interval => 30,
  },
  'bigip2.example.com' => {
    type         => 'f5',
    url          => 'https://admin:fffff55555@10.0.2.245/',
    run_interval => 30,
  },
}
```

#### Manage Multiple Devices via Hiera:

Declare multiple `device_manager` resources via the `device_manager::devices` key applied to the proxy Puppet agent via Hiera:

```yaml
---
device_manager::devices:
  bigip1.example.com:
    type:         'f5'
    url:          'https://admin:fffff55555@10.0.1.245/'
    run_interval: 30
  bigip2.example.com:
    type:         'f5'
    url:          'https://admin:fffff55555@10.0.2.245/'
    run_interval: 30
```

... and declare the `device_manager::devices` class in a manifest applied to the proxy Puppet agent:

```puppet
node 'agent.example.com'  {
  include device_manager::devices
}
```

### Run `puppet device`

Declaring these resources will configure `device.conf` and apply the base class of associated device modules on the proxy Puppet agent, allowing it to execute `puppet device` runs on behalf of its configured devices:

```bash
puppet device --verbose --target bigip.example.com
```

#### Signing Certificates

The first run of `puppet device` for a device will generate a certificate request for the device:

```bash
Info: Creating a new SSL key for bigip.example.com
Info: Caching certificate for ca
Info: csr_attributes file loading from /opt/puppetlabs/puppet/cache/devices/bigip.example.com/csr_attributes.yaml
Info: Creating a new SSL certificate request for bigip.example.com
Info: Certificate Request fingerprint (SHA256): ...
Info: Caching certificate for ca
```

Unless [autosign](https://puppet.com/docs/puppet/latest/ssl_autosign.html) is enabled, the following (depending upon `waitforcert`) will be output:

```bash
Notice: Did not receive certificate
Notice: Did not receive certificate
Notice: Did not receive certificate
...
```

Or:

```bash
Exiting; no certificate found and waitforcert is disabled
```

On the master, execute the following to sign the certificate for the device:

```bash
puppet cert sign bigip.example.com
```

This will output that the certificate for the device has been signed:

```bash
Signing Certificate Request for:
  "bigip.example.com" (SHA256) ...
Notice: Signed certificate request for cisco.example.com
Notice: Removing file Puppet::SSL::CertificateRequest bigip.example.com at '/etc/puppetlabs/puppet/ssl/ca/requests/bigip.example.com.pem'
```

## Parameters

### name

Data type: String

This parameter is optional, and defaults to the title of the resource.

Specifies the `certname` of the device.

### ensure

Data type: String

This parameter is optional, with valid options of 'present' (the default) and 'absent'.

Setting to 'absent' deletes the device from `device.conf` and the `devices` fact, and negates the effect of any other parameters.

### type

Data type: String

Specifies the type of the device in `device.conf` on the proxy Puppet agent. This identifies the module used to access the device.

### url

Data type: String

This parameter is required for devices that do not use the Puppet Resource API: refer to the associated device module documentation for details. The `url` and `credentials` parameters are mutually exclusive.

Specifies the URL of the device in `device.conf` on the proxy Puppet agent.

### credentials

Data type: Hash

This parameter is required for devices that use the Puppet Resource API: refer to the associated device module documentation for details. The `credentials` and `url` parameters are mutually exclusive.

Specifies the credentials of the device in a HOCON file in `confdir/devices`, and sets that file as the `url` of the device in `device.conf`, on the proxy Puppet agent.

```puppet
device_manager {'cisco.example.com':
  type        => 'cisco_ios',
  credentials => {
                  address         => '10.0.0.246',
                  port            => 22,
                  username        => 'admin',
                  password        => 'password',
                  enable_password => 'password',
  },
}
```

### debug

Data type: Boolean

This parameter is optional, with a default of false.

Specifies transport-level debugging of the device in `device.conf` on the proxy Puppet agent, and is limited to debugging the telnet and ssh transports.

Note: This parameter specifies the `debug` property defined in: [Config Files: device.conf](https://puppet.com/docs/puppet/latest/config_file_device.html) rather than the `--debug` option defined in: [Man Page: puppet device](https://puppet.com/docs/puppet/latest/man/device.html).

### include_module

Data type: Boolean

This parameter is optional, with a default of true.

Specifies automatically including the base class (if one is defined) of the associated device module (specified by the `type` parameter) on the proxy Puppet agent.

Device modules may implement a base class that applies an `install` class. Automatically including that class will automatically install any requirements of the device module.

### run_interval

Data type: Integer

This parameter is optional, with a default of 0.

Setting `run_interval` to a value between 1 and 1440 will create a Cron (or on Windows, a Scheduled Task) resource for the device that executes `puppet device --target` every `run_interval` minutes (with a randomized offset) on the proxy Puppet agent. When creating a Cron resource, values greater than thirty minutes will be rounded up to the nearest hour.

[comment]: # (Doing so avoids impractical cron mathematics.)

```puppet
device_manager {'bigip.example.com':
  type         => 'f5',
  url          => 'https://admin:fffff55555@10.0.0.245/',
  run_interval => 30,
}
```

Note: On versions of Puppet (lower than Puppet 5.x.x) that do not support `puppet device --target`, this parameter will instead create one Cron (or Scheduled Task) resource that executes `puppet device` for all devices in `device.conf` every 60 minutes (at a randomized minute) on the proxy Puppet agent.

## Orchestration

### Puppet Tasks

On versions of Puppet Enterprise (2017.3.x or higher) that support Puppet Tasks, this module provides a `device_manager::run_puppet_device` task which can be used by the `puppet task` command to orchestrate a `puppet device` run on the proxy Puppet agent. Help for this task is available via: `puppet task show device_manager::run_puppet_device` command.

#### Examples:

To run `puppet device` for all devices in `device.conf` on the specified proxy Puppet agent:

```bash
puppet task run device_manager::run_puppet_device --nodes 'agent.example.com'
```

To run `puppet device` for all devices in `device.conf` on the proxy Puppet agent identified by a PuppetDB query:

```bash
puppet task run device_manager::run_puppet_device --query 'inventory { facts.devices."bigip.example.com" = true }'
```

To run `puppet device --target` for a specific device in `device.conf` on the proxy Puppet agent identified by a PuppetDB query:

```bash
puppet task run device_manager::run_puppet_device --query 'inventory { facts.devices."bigip.example.com" = true }' target=bigip.example.com
```

[comment]: # (Alternate tag-query: --query 'resources[certname] { tag = "device_bigip.example.com"}')

## Reference

For more information, see:

* [Man Page: puppet device](https://puppet.com/docs/puppet/latest/man/device.html)
* [Config Files: device.conf](https://puppet.com/docs/puppet/latest/config_file_device.html)
* [Running Tasks](https://puppet.com/docs/pe/latest/orchestrator/running_tasks.html)

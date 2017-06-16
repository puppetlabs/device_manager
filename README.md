# puppet_device

#### Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Parameters](#parameters)
1. [Limitations](#limitations)
1. [Reference](#reference)

## Description

Devices need a (proxy) puppet agent to collect facts, retrieve and apply catalogs, and store reports.

This module manages the configuration of devices used by `puppet device` on puppet agents.

This module also provides the potential for indirect orchestration of `puppet device` runs.

## Usage

Install the `puppet_device` module:

~~~
puppet module install tkishel-puppet_device
~~~

Declare `puppet_device` resource(s):

~~~
puppet_device { 'bigip':
  type   => 'f5',
  url    => 'https://admin:fffff55555@10.0.0.245/',
  run    => true,
}
~~~

Note that the 'f5' device type is used as an example: this module is not limited to 'f5' devices.

## Parameters

### title

Data type: String

Specifies the certname of the device.

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

### run

Data type: Boolean

This parameter is optional, with a default of false.

Specifies whether to run `puppet device` during each `puppet agent` run on the puppet agent.

Setting to true, it can be combined with Orchestration (and a PQL query) to indirectly orchestrate a `puppet device` run on the puppet agent for a device:

~~~
puppet job run --query 'resources[certname, type, title, parameters] { type = "Puppet_device" and title = "bigip" and parameters.ensure = "present"}'
~~~

The following illustrates the PQL query:

~~~
[root@pe-201645-master ~]# puppet query 'resources[certname, type, title, parameters] { type = "Puppet_device" and title = "bigip" and parameters.ensure = "present"}'
[ {
  "certname" : "pe-201645-master.puppetdebug.vlan",
  "type" : "Puppet_device",
  "title" : "bigip",
  "parameters" : {
    "ensure" : "present",
    "type" : "f5",
    "url" : "https://admin:fffff55555@10.0.0.245/",
    "run" : true,
  }
}
~~~

## Limitations

See manifests/todo.pp

## Reference

This module manages `device.conf` and `<confdir>/facter/facts.d/puppet_devices.yaml`, including entries for each `puppet_device` resource declared on the puppet agent.

For more information about devices, see:

https://docs.puppet.com/puppet/latest/man/device.html
https://docs.puppet.com/puppet/latest/config_file_device.html

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

## Usage

Install the `puppet_device` module:

~~~
puppet module install tkishel-puppet_device
~~~

Declare the `puppet_device` class:

~~~
puppet_device { 'bigip':
  type   => 'f5',
  url    => 'https://admin:fffff55555@10.0.0.245/',
  run    => true,
}

puppet_device { 'bigipa':
  type   => 'f5',
  url    => 'https://admin:fffff55555@10.0.0.246/',
  run    => true,
}
~~~

Note that the `f5` device type is used as an example. This module is not limited to `f5` devices.

## Parameters

### title

Data type: String

Specifies the certname of the device.

### ensure

Data type: String

Setting to 'absent' deletes the device from `device.conf` and the `puppet_devices` fact, and negates the effect of any other parameters. 

Valid options: 'present' (the default) and 'absent'.

### type

Data type: String

Specifies the type of the device.

### url

Data type: String

Specifies the URL used to configure to the device.

### run

Data type: Boolean

Specifies whether to run `puppet device` during each `puppet agent` run on the puppet agent.

This parameter is optional, and can be combined with Orchestration (and a PQL query) to indirectly orchestrate a `puppet device` run on the puppet agent for a device:

~~~
puppet job run --query 'resources[certname, type, title, parameters] { type = "Puppet_device" and title = "bigip" and parameters.ensure = "present"}'
~~~

This is based upon the following PQL query:

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

This module manages `device.conf` and `<confdir>/facter/facts.d/puppet_devices.yaml` ... adding entries for each `puppet_device` resource declared on the puppet agent.

https://docs.puppet.com/puppet/latest/config_file_device.html

https://docs.puppet.com/puppet/latest/man/device.html
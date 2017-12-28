require 'spec_helper'

describe 'puppet_device' do

  context 'on Linux, running Puppet 5.0, with values for all device.conf parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.0.0',
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf',
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :puppet_vardir          => '/opt/puppetlabs/puppet/cache',
        :osfamily               => 'redhat',
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

  context 'on Windows, running Puppet 5.0, with values for all device.conf parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.0.0',
        :puppet_deviceconfig    => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppetlabs_confdir     => 'C:/ProgramData/PuppetLabs/puppet',
        :puppetlabs_vardir      => 'C:/ProgramData/PuppetLabs/puppet/cache',
        :osfamily               => 'windows',
        :env_windows_installdir => "C:\\Program Files\\Puppet Labs\\Puppet"
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

  context 'on Linux, running Puppet 4.10, with run_via_cron' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_cron => true,
      }
    }
    let(:facts) {
      {
        :puppetversion          => '4.10.0',
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf',
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :puppet_vardir          => '/opt/puppetlabs/puppet/cache',
        :osfamily               => 'redhat',
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_cron__device('bigip.example.com') }
    it {
      is_expected.to contain_cron('run puppet_device').with(
        'command' => '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root',
      )
    }
  end

  context 'on Linux, running Puppet 5.0, with run_via_cron' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_cron => true,
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.0.0',
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf',
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :puppet_vardir          => '/opt/puppetlabs/puppet/cache',
        :osfamily               => 'redhat',
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_cron__device('bigip.example.com') }
    it {
      is_expected.to contain_cron('run puppet_device target bigip.example.com').with(
        'command' => '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root --target bigip.example.com',
      )
    }
  end

  context 'on Windows, running Puppet 5.0, with run_via_cron' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_cron => true,
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.0.0',
        :puppet_deviceconfig    => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppetlabs_confdir     => 'C:/ProgramData/PuppetLabs/puppet',
        :puppetlabs_vardir      => 'C:/ProgramData/PuppetLabs/puppet/cache',
        :osfamily               => 'windows',
        :env_windows_installdir => "C:\\Program Files\\Puppet Labs\\Puppet"
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_scheduled_task__device('bigip.example.com') }
    it { 
      is_expected.to contain_scheduled_task('run puppet_device target bigip.example.com').with(
        'command'   => "C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet",
      )
    }
  end

  context 'on Linux, running Puppet 5.0, with run_via_exec' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => 'present',
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_exec => true
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.0.0',
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf',
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :puppet_vardir          => '/opt/puppetlabs/puppet/cache',
        :osfamily               => 'redhat',
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_puppet_device__run__via_exec__device('bigip.example.com') }
    it {
      is_expected.to contain_exec('run puppet_device target bigip.example.com').with_command(
        '"/opt/puppetlabs/puppet/bin/puppet" device --waitforcert=0 --user=root --target bigip.example.com',
      )
    }
  end

  context 'on Linux, running Puppet 5.0, with run_via_cron and run_via_exec parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_exec => true,
        :run_via_cron => true,
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.0.0',
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf',
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :puppet_vardir          => '/opt/puppetlabs/puppet/cache',
        :osfamily               => 'redhat',
      }
    }

    it { is_expected.to raise_error(%r{are mutually-exclusive}) }
  end

end

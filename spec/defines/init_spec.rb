require 'spec_helper'

describe 'puppet_device' do
  context 'on Linux, with values for all device.conf parameters' do
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
        :puppetversion          => '4.10.0',
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf',
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :puppetlabs_vardir      => '/opt/puppetlabs/puppet/cache',
        :osfamily               => 'redhat',
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

  context 'on Windows, with values for all device.conf parameters' do
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
        :puppetversion          => '4.10.0',
        :puppet_deviceconfig    => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppetlabs_confdir     => 'C:/ProgramData/PuppetLabs/puppet/etc',
        :puppetlabs_vardir      => 'C:/ProgramData/PuppetLabs/puppet/cache',
        :osfamily               => 'windows',
        :env_windows_installdir => 'C:/Program Files/Puppet Labs/Puppet/bin'
      }
    }

    it { is_expected.to contain_puppet_device('bigip.example.com') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

  context 'running Puppet 5.0, on Linux, with values for all device.conf parameters' do
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

  context 'running Puppet 5.0, on Linux, with cron parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
        :run_via_cron => true,
        :run_via_cron_hour   => '23',
        :run_via_cron_minute => '59',
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
      is_expected.to contain_cron('run puppet_device target bigip.example.com').with_command(
        '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root --target bigip.example.com',
      )
    }
  end

  context 'running Puppet 5.4, on Linux, with cron parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
        :run_via_cron => true,
        :run_via_cron_hour   => '23',
        :run_via_cron_minute => '59',
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.4.0',
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
      is_expected.to contain_cron('run puppet_device target bigip.example.com').with_command(
        '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --target bigip.example.com',
      )
    }
  end

  context 'running Puppet 5.0, on Linux, with cron and without hour or minute parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
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

    it { is_expected.to raise_error(%r{run_via_cron_hour and run_via_cron_minute cannot both be absent or undefined}) }
  end

  context 'running Puppet 5.0, on Linux, with exec parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => 'present',
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
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

  context 'running Puppet 5.4, on Linux, with exec parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => 'present',
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
        :run_via_exec => true
      }
    }
    let(:facts) {
      {
        :puppetversion          => '5.4.0',
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
        '"/opt/puppetlabs/puppet/bin/puppet" device --waitforcert=0 --target bigip.example.com',
      )
    }
  end

  context 'running Puppet 5.0, on Linux, with cron and exec parameters' do
    let(:title)  { 'bigip.example.com' }
    let(:params) {
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
        :run_via_cron => true,
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

    it { is_expected.to raise_error(%r{run_via_cron and run_via_exec are mutually-exclusive}) }
  end
end

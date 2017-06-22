require 'spec_helper'

describe 'puppet_device' do

  context 'with values for all parameters' do
    let(:title)  { 'bigip' }
    let(:params) { {
        :ensure => 'present',
        :type   => 'f5',
        :url    => 'https://admin:fffff55555@10.0.0.245/',
        :debug  => true,
        :run    => true,
      }
    }

    let(:facts) { {
        :puppet_deviceconfig    => '/etc/puppetlabs/puppet/device.conf ', 
        :puppetlabs_confdir     => '/etc/puppetlabs',
        :osfamily               => 'redhat',
        :env_windows_installdir => "C:/Program Files/Puppet Labs/Puppet/bin",
      }
    }

    it { is_expected.to contain_puppet_device('bigip') }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
  end

end

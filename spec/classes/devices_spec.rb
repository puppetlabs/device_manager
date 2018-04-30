require 'spec_helper'

describe 'puppet_device::devices' do
  let(:params) do
    { devices: {
      'param.example.com' => {
        'type' => 'f5',
        'url'  => 'https://admin:fffff55555@10.0.1.245/',
        'run_interval' => 30,
      },
    } }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts[:aio_agent_version] = '5.5.1'
        if os =~ %r{^windows}i
          os_facts.merge!(puppet_settings_deviceconfig: 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
                          puppet_settings_confdir: 'C:/ProgramData/PuppetLabs/puppet',
                          env_windows_installdir: 'C:\\Program Files\\Puppet Labs\\Puppet')
        else
          os_facts[:puppet_settings_deviceconfig] = '/etc/puppet/device.conf'
          os_facts[:puppet_settings_confdir] = '/etc/puppet'
        end
        os_facts
      end

      it { is_expected.to compile }
      it { is_expected.to contain_puppet_device('hiera.example.com') }
      it { is_expected.to contain_puppet_device('param.example.com') }
    end
  end
end

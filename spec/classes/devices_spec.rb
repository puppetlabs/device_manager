require 'spec_helper'

describe 'device_manager::devices' do
  let(:params) do
    { devices: {
      'params_url.example.com' => {
        'type' => 'f5',
        'url'  => 'https://admin:password@10.0.1.245/',
        'run_interval' => 33,
      },
      'params_credentials.example.com' => {
        'type' => 'cisco_ios',
        'credentials'  => { 'user' => 'admin', 'password' => 'password', 'port' => 44 },
        'run_interval' => 33,
      },
    } }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts[:aio_agent_version] = '5.5.1'
        if os =~ %r{^windows}i
          os_facts[:puppet_settings_deviceconfig] = 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf'
          os_facts[:puppet_settings_confdir]      = 'C:/ProgramData/PuppetLabs/puppet'
          os_facts[:env_windows_installdir]       = 'C:\\Program Files\\Puppet Labs\\Puppet'
        else
          os_facts[:puppet_settings_deviceconfig] = '/etc/puppet/device.conf'
          os_facts[:puppet_settings_confdir]      = '/etc/puppet'
        end
        os_facts
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_device_manager('hiera.example.com')
          .with('type' => 'f5',
                'url' => 'https://admin:password@10.0.1.245/',
                'run_interval' => 33)
      }
      it {
        is_expected.to contain_device_manager('hiera_with_global_default.example.com')
          .with('type'         => 'f5',
                'url'          => 'https://admin:password@10.0.2.245/',
                'run_interval' => 66)
      }
      it {
        is_expected.to contain_device_manager('hiera_with_type_defaults.example.com')
          .with('type'         => 'cisco_ios',
                'credentials'  => { 'port' => 22, 'address' => '10.0.0.246', 'username' => 'admin', 'password' => 'password', 'enable_password' => 'password' },
                'run_interval' => 99)
      }

      it {
        is_expected.to contain_device_manager('params_url.example.com')
          .with('type'         => 'f5',
                'url'          => 'https://admin:password@10.0.1.245/',
                'run_interval' => 33)
      }
      it {
        is_expected.to contain_device_manager('params_credentials.example.com')
          .with('type' => 'cisco_ios',
                'credentials'  => { 'user' => 'admin', 'password' => 'password', 'port' => 44 },
                'run_interval' => 33)
      }
    end
  end
end

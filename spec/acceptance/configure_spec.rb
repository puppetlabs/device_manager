require 'spec_helper_acceptance'

describe 'configure' do
  fqdn = fact('fqdn')

  manifest = <<-EOS
File { backup => false }
node '#{fqdn}' {
  include cisco_ios::proxy
  device_manager {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:password@10.0.0.245/',
    run_interval => 30,
  }
  device_manager {'cisco.example.com':
    type        => 'cisco_ios',
    credentials => {
      address         => '10.64.21.10',
      port            => 22,
      username        => 'root',
      password        => 'eq3e2jM6m8AVvT9',
      enable_password => 'eq3e2jM6m8AVvT9',
    },
  }
}
node default {}
EOS

  manifest_with_include_devices = <<-EOS
File { backup => false }
node '#{fqdn}' {
  include cisco_ios::proxy
  device_manager {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:password@10.0.0.245/',
    run_interval => 30,
  }
  device_manager {'cisco.example.com':
    type        => 'cisco_ios',
    credentials => {
      address         => '10.64.21.10',
      port            => 22,
      username        => 'root',
      password        => 'eq3e2jM6m8AVvT9',
      enable_password => 'eq3e2jM6m8AVvT9',
    },
  }
  include device_manager::devices
}
node default {}
EOS

  yaml_with_devices = <<-EOS
---
device_manager::devices:
  cisco_via_hiera.example.com:
    type:         'cisco_ios'
    credentials:
      address:         '10.64.21.10'
      port:            22
      username:        'admin'
      password:        'eq3e2jM6m8AVvT9'
      enable_password: 'eq3e2jM6m8AVvT9'
device_manager::devices::defaults:
  run_interval: 60
EOS

  yaml_with_devices_with_ensure_absent = <<-EOS
---
device_manager::devices:
  cisco_via_hiera.example.com:
    type:         'cisco_ios'
    credentials:
      address:         '10.64.21.10'
      port:            22
      username:        'admin'
      password:        'eq3e2jM6m8AVvT9'
      enable_password: 'eq3e2jM6m8AVvT9'
device_manager::devices::defaults:
  ensure:       'absent'
  run_interval: 60
EOS

  context 'device management via device_manager' do
    it 'define device management in site.pp on the master' do
      define_site_pp(manifest)
    end
    it 'define device management on the proxy agent' do
      run_puppet_agent(allow_changes: true)
      run_puppet_agent(allow_changes: false)
    end
    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{bigip.example.com} }
      it { is_expected.to contain %r{cisco.example.com} }
    end
    describe file('/etc/puppetlabs/puppet/devices/cisco.example.com.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{address} }
    end
    it 'cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).to match(%r{bigip.example.com})
      expect(result).not_to match(%r{cisco.example.com})
    end
  end

  context 'device management via device_manager and device_manager::devices' do
    it 'define device management in hiera on the master' do
      define_site_pp(manifest_with_include_devices)
      define_common_yaml(yaml_with_devices)
    end
    it 'define device management on the proxy agent' do
      run_puppet_agent(allow_changes: true)
      run_puppet_agent(allow_changes: false)
    end
    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{cisco_via_hiera.example.com} }
    end
    describe file('/etc/puppetlabs/puppet/devices/cisco_via_hiera.example.com.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{address} }
    end
    it 'cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).to match(%r{cisco_via_hiera.example.com})
    end
  end

  context 'undefine device management via device_manager::devices via ensure absent' do
    it 'undefine device management in hiera on the master' do
      define_site_pp(manifest_with_include_devices)
      define_common_yaml(yaml_with_devices_with_ensure_absent)
    end
    it 'undefine device management on the proxy agent' do
      run_puppet_agent(allow_changes: true)
      run_puppet_agent(allow_changes: false)
    end
    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.not_to contain %r{cisco_via_hiera.example.com} }
    end
    describe file('/etc/puppetlabs/puppet/devices/cisco_via_hiera.example.com.conf') do
      it { is_expected.not_to be_file }
    end
    it 'undefine cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).not_to match(%r{cisco_via_hiera.example.com})
    end
  end

  context 'device certificate' do
    it 'purge device on the master and the proxy agent' do
      run_puppet_node_purge('cisco.example.com')
      reset_agent_device_cache('cisco.example.com')
    end
  end
end

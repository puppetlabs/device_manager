require 'spec_helper_acceptance'

describe 'configure' do
  let(:fqdn) { fact('fqdn') }

  let(:manifest) do
    <<-EOS
File { backup => false }
node '#{fqdn}' {
  include resource_api::install
  device_manager {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:password@10.0.0.245/',
    run_interval => 30,
  }
  device_manager {'spinner.example.com':
    type        => 'spinner',
    credentials => {
      facts_cpu_time  => 0,
      facts_wait_time => 0,
      get_cpu_time    => 0,
      get_wait_time   => 0,
    },
    include_module => false,
  }
}
node default {}
EOS
  end

  let(:manifest_with_include_devices) do
    <<-EOS
File { backup => false }
node '#{fqdn}' {
  include resource_api::install
  device_manager {'bigip.example.com':
    type         => 'f5',
    url          => 'https://admin:password@10.0.0.245/',
    run_interval => 30,
  }
  device_manager {'spinner.example.com':
    type        => 'spinner',
    credentials => {
      facts_cpu_time  => 0,
      facts_wait_time => 0,
      get_cpu_time    => 0,
      get_wait_time   => 0,
    },
    include_module => false,
  }
  include device_manager::devices
}
node default {}
EOS
  end

  let(:yaml_with_devices) do
    <<-EOS
---
device_manager::devices:
  spinner_via_hiera.example.com:
    type: 'spinner'
    credentials:
      facts_cpu_time: 0
      facts_wait_time: 0
      get_cpu_time: 0
      get_wait_time: 0
    include_module: false
device_manager::devices::defaults:
  run_interval: 60
EOS
  end

  let(:yaml_with_devices_with_ensure_absent) do
    <<-EOS
---
device_manager::devices:
  spinner_via_hiera.example.com:
    type: 'spinner'
    credentials:
      facts_cpu_time: 0
      facts_wait_time: 0
      get_cpu_time: 0
      get_wait_time: 0
    include_module: false
device_manager::devices::defaults:
  ensure:       'absent'
  run_interval: 60
EOS
  end

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
      it { is_expected.to contain %r{spinner.example.com} }
    end
    describe file('/etc/puppetlabs/puppet/devices/spinner.example.com.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{facts_cpu_time} }
    end
    it 'cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).to match(%r{bigip.example.com})
      expect(result).not_to match(%r{spinner.example.com})
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
      it { is_expected.to contain %r{spinner_via_hiera.example.com} }
    end
    describe file('/etc/puppetlabs/puppet/devices/spinner_via_hiera.example.com.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{facts_cpu_time} }
    end
    it 'cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).to match(%r{spinner_via_hiera.example.com})
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
      it { is_expected.not_to contain %r{spinner_via_hiera.example.com} }
    end
    describe file('/etc/puppetlabs/puppet/devices/spinner_via_hiera.example.com.conf') do
      it { is_expected.not_to be_file }
    end
    it 'undefine cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).not_to match(%r{spinner_via_hiera.example.com})
    end
  end

  context 'device certificate' do
    it 'purge device on the master and the proxy agent' do
      run_puppet_node_purge('spinner.example.com')
      reset_agent_device_cache('spinner.example.com')
    end
  end
end

require 'spec_helper_acceptance'

describe 'configure' do
  context 'device management' do
    it 'define device management in site.pp on the master' do
      fqdn = fact('fqdn')

      manifest = <<-EOS
  node '#{fqdn}' {
    device_manager {'bigip.example.com':
      type         => 'f5',
      url          => 'https://admin:fffff55555@10.0.0.245/',
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

      define_site_pp(manifest)
    end

    it 'define device management on the proxy agent' do
      run_puppet_agent(allow_changes: true)
      run_puppet_agent(allow_changes: false)
    end

    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{[bigip.example.com]} }
      it { is_expected.to contain %r{type f5} }
      it { is_expected.to contain %r{[cisco.example.com]} }
      it { is_expected.to contain %r{type cisco_ios} }
    end

    describe file('/etc/puppetlabs/puppet/devices/cisco.example.com.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{address} }
    end

    it 'cron for device with run_interval on the proxy agent' do
      result = on(default, 'crontab -l').stdout
      expect(result).to match(%r{puppet device})
      expect(result).to match(%r{bigip.example.com})
    end
  end

  context 'device certificate' do
    it 'purge device on the master and the proxy agent' do
      run_puppet_node_purge('cisco.example.com')
      reset_agent_device_cache('cisco.example.com')
    end
  end
end

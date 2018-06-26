require 'spec_helper_acceptance'

describe 'configure' do
  context 'basic setup' do
    it 'edit site.pp and run the agent' do
      fqdn = fact('fqdn')
      pp = <<-EOS
  node '#{fqdn}' {
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
    device_manager {'bigip.example.com':
      type         => 'f5',
      url          => 'https://admin:fffff55555@10.0.0.245/',
      run_interval => 30,
    }
  }
  node default {}
      EOS
      make_site_pp(pp)
      run_agent(allow_changes: true)
      run_agent(allow_changes: false)
    end

    # check device.conf is created
    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{[cisco.example.com]} }
      it { is_expected.to contain %r{type cisco_ios} }
      it { is_expected.to contain %r{[bigip.example.com]} }
      it { is_expected.to contain %r{type f5} }
    end
  end

  context 'puppet device' do
    it 'generate and sign a certificate request' do
      run_cert_reset('cisco.example.com')
      run_device_generate_csr('cisco.example.com')
      run_cert_sign('cisco.example.com')
    end
    it 'runs puppet device' do
      run_device('cisco.example.com', allow_changes: false)
    end
  end

  context 'puppet device tasks' do
    it 'puppet task run' do
      # PE vs FOSS
      ENV['PUPPET_INSTALL_TYPE'] = 'pe'
      run_puppet_access_login(user: 'admin')
      proxy_cert_name = fact('fqdn')
      device_cert_name = 'cisco.example.com'
      # TODO: Read the default certificate fingerprint and add to regex below.
      run_and_expect(proxy_cert_name, device_cert_name, [%r{status : success}, %r{fingerprint :}])
    end
  end
end

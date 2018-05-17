require 'spec_helper_acceptance'
describe 'configure' do
  context 'basic setup' do
    it 'edit site.pp and run the agent' do
      fqdn = fact('fqdn')
      pp = <<-EOS
      node '#{fqdn}' {
        device_manager {'bigip.example.com':
          type         => 'f5',
          url          => 'https://admin:fffff55555@10.0.0.245/',
          run_interval => 30,
        }
      }
      EOS
      make_site_pp(pp)
      run_agent(allow_changes: true)
      run_agent(allow_changes: false)
    end

    # check device.conf is created
    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{[bigip.example.com]} }
      it { is_expected.to contain %r{type f5} }
    end

    # check crontab has an entry
    it 'crontab entry' do
      result = on(default, 'crontab -l').stdout
      expect(result).to match(%r{puppet device})
    end

    it 'run puppet device' do
      # check the cert is created
      # sign the cert
    end
  end
end

require 'spec_helper_acceptance'

describe 'run' do
  context 'puppet device' do
    it 'generate certificate request for device on the proxy agent' do
      run_puppet_device_generate_csr('cisco.example.com')
    end
    it 'sign certificate request on the master' do
      run_puppet_cert_sign('cisco.example.com')
    end
    it 'run puppet device on the proxy agent' do
      run_puppet_device('cisco.example.com', allow_changes: false)
    end
  end

  context 'puppet task' do
    it 'run_puppet_device' do
      host_cert_name = fact('fqdn')
      device_cert_name = 'cisco.example.com'
      params = "target=#{device_cert_name}"
      device_cert_fingerprint = run_puppet_cert_fingerprint(device_cert_name)
      result = run_puppet_task(task_name: 'device_manager::run_puppet_device', host: host_cert_name, params: params)
      expect(result).to match(%r{status : success})
      expect(result).to match(%r{fingerprint : #{device_cert_fingerprint}})
    end
  end
end

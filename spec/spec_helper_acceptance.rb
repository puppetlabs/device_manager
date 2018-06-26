require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker-task_helper'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'pry'

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

def make_site_pp(pp)
  base_path = '/etc/puppetlabs/code/environments/production/'
  path = File.join(base_path, 'manifests')
  on master, "mkdir -p #{path}"
  create_remote_file(master, File.join(path, 'site.pp'), pp)
  return if ENV['PUPPET_INSTALL_TYPE'] != 'foss'
  on master, "chown -R #{master['user']}:#{master['group']} #{path}"
  on master, "chmod -R 0755 #{path}"
  on master, "service #{master['puppetservice']} restart"
  wait_for_master(3)
end

def run_agent(options = { allow_changes: true })
  acceptable_exit_codes = (options[:allow_changes] == false) ? 0 : [0, 2]
  on(default, puppet('agent', '-t'),  acceptable_exit_codes: acceptable_exit_codes)
end

def run_device_generate_csr(cert_name)
  acceptable_exit_codes = 1
  on(default, puppet('device', '--verbose', '--trace', '--waitforcert=0', '--target', cert_name), acceptable_exit_codes: acceptable_exit_codes) do |result|
    expect(result.stdout).to match(%r{Exiting; no certificate found and waitforcert is disabled})
  end
end

def run_cert_reset(cert_name)
  on master, "puppet node purge #{cert_name}"
  on default, "rm -rf /opt/puppetlabs/puppet/cache/devices/#{cert_name}"
end

def run_cert_sign(cert_name = nil)
  if cert_name
    on(master, puppet('cert', 'sign', '--debug', cert_name), acceptable_exit_codes: [0, 1]).stdout
  else
    on(master, puppet('cert', 'sign', '--all', '--debug'), acceptable_exit_codes: [0, 1]).stdout
  end
end

def run_device(cert_name, options = { allow_changes: true })
  acceptable_exit_codes = (options[:allow_changes] == false) ? 0 : [0, 2]
  on(default, puppet('device', '--verbose', '--trace', '--waitforcert=0', '--target', cert_name), acceptable_exit_codes: acceptable_exit_codes) do |result|
    # on(default, puppet('device','--verbose','--color','false','--user','root','--trace','--server',master.to_s), { :acceptable_exit_codes => acceptable_exit_codes }) do |result|
    if options[:allow_changes] == false
      expect(result.stdout).not_to match(%r{^Notice: /Stage\[main\]})
    end
    expect(result.stderr).not_to match(%r{^Error:})
    expect(result.stderr).not_to match(%r{^Warning:})
  end
end

def run_and_expect(proxy_cert_name, device_cert_name, regexes)
  expect_multiple_regexes(result: run_task(task_name: 'device_manager::run_puppet_device', host: proxy_cert_name, params: "target=#{device_cert_name}"), regexes: regexes)
end


def run_resource(cert_name, resource_type, resource_title = nil)
  if resource_title
    on(master, puppet('device', '--target', cert_name, '--resource', resource_type, resource_title, '--trace'), acceptable_exit_codes: [0, 1]).stdout
  else
    on(master, puppet('device', '--target', cert_name, '--resource', resource_type, '--trace'), acceptable_exit_codes: [0, 1]).stdout
  end
end

RSpec.configure do |c|
  c.before :suite do
    unless ENV['BEAKER_TESTMODE'] == 'local'
      unless ENV['BEAKER_provision'] == 'no'
        install_module_from_forge('puppetlabs-cisco_ios', '0.2.0')
        install_module_from_forge('f5-f5', '1.8.0')
      end
      hosts.each do |host|
      end
    end
  end
end

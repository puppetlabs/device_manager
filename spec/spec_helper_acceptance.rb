require 'beaker-pe'
require 'beaker-puppet'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker-task_helper'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'pry'

if ENV['BEAKER_provision'] != 'no'
  run_puppet_install_helper
  configure_type_defaults_on(hosts)
  install_module_on(hosts)
  install_module_dependencies_on(hosts)
end

RSpec.configure do |c|
  c.before :suite do
    run_puppet_access_login(user: 'admin')
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

def define_common_yaml(yaml)
  path = '/etc/puppetlabs/code/environments/production/data'
  on master, "mkdir -p #{path}"
  create_remote_file(master, File.join(path, 'common.yaml'), yaml)
  if ENV['PUPPET_INSTALL_TYPE'] == 'foss'
    on master, "chown -R puppet:puppet #{path}"
  else
    on master, "chown -R pe-puppet:pe-puppet #{path}"
  end
  on master, "chmod -R 0755 #{path}"
end

def define_site_pp(manifest)
  path = '/etc/puppetlabs/code/environments/production/manifests'
  on master, "mkdir -p #{path}"
  create_remote_file(master, File.join(path, 'site.pp'), manifest)
  if ENV['PUPPET_INSTALL_TYPE'] == 'foss'
    on master, "chown -R puppet:puppet #{path}"
    on master, "service #{master['puppetservice']} restart"
    wait_for_master(3)
  else
    on master, "chown -R pe-puppet:pe-puppet #{path}"
  end
  on master, "chmod -R 0755 #{path}"
end

def reset_agent_device_cache(cert_name)
  on default, "rm -rf /opt/puppetlabs/puppet/cache/devices/#{cert_name}"
end

def run_puppet_node_purge(cert_name)
  on(master, puppet('node', 'purge', cert_name), acceptable_exit_codes: [0, 1]).stdout
end

def run_puppet_cert_sign(cert_name = nil)
  puppet_version = on master, puppet('--version')
  cert = cert_name ? cert_name : '--all'

  if version_is_less(puppet_version.output, '5.99')
    on(master, puppet('cert', 'sign', cert), acceptable_exit_codes: [0, 1]).stdout
  else
    on(master, "puppetserver ca sign --certname #{cert}", acceptable_exit_codes: [0, 1]).stdout
  end
end

def run_puppet_cert_fingerprint(cert_name)
  fingerprint = nil
  puppet_version = on master, puppet('--version')
  if version_is_less(puppet_version.output, '5.99')
    result = on(master, puppet('cert', 'fingerprint', cert_name), acceptable_exit_codes: 0).stdout
    if (matched = result.chomp.match(%r{\(\w+\) (?<fingerprint>.*)$}))
      fingerprint = matched[:fingerprint]
    end
  else
    result = on(master, "puppetserver ca list --all | grep #{cert_name}", acceptable_exit_codes: 0).stdout
    if (matched = result.chomp.match(%r{\(\w+\) (?<fingerprint>.*[^\W])(?<alt> alt names:.*[^$])?$}))
      fingerprint = matched[:fingerprint]
    end
  end
  fingerprint.strip
end

def run_puppet_agent(options = { allow_changes: true })
  acceptable_exit_codes = (options[:allow_changes] == false) ? 0 : [0, 2]
  on(default, puppet('agent', '-t'), acceptable_exit_codes: acceptable_exit_codes)
end

def run_puppet_device_generate_csr(cert_name)
  acceptable_exit_codes = 1
  on(default, puppet('device', '--verbose', '--waitforcert=0', '--target', cert_name), acceptable_exit_codes: acceptable_exit_codes) do |result|
    expect(result.stdout).to match(%r{Exiting; no certificate found and waitforcert is disabled})
  end
end

# Use '--trace', '--color', 'false' for more information.

def run_puppet_device(cert_name, options = { allow_changes: true })
  acceptable_exit_codes = (options[:allow_changes] == false) ? 0 : [0, 2]
  on(default, puppet('device', '--verbose', '--waitforcert=0', '--target', cert_name), acceptable_exit_codes: acceptable_exit_codes) do |result|
    if options[:allow_changes] == false
      expect(result.stdout).not_to match(%r{^Notice: /Stage\[main\]})
    end
    expect(result.stderr).not_to match(%r{^Error:})
    expect(result.stderr).not_to match(%r{^Warning:})
  end
end

def run_puppet_device_resource(cert_name, resource_type, resource_title = nil)
  if resource_title
    on(default, puppet('device', '--trace', '--target', cert_name, '--resource', resource_type, resource_title), acceptable_exit_codes: [0, 1]).stdout
  else
    on(default, puppet('device', '--trace', '--target', cert_name, '--resource', resource_type), acceptable_exit_codes: [0, 1]).stdout
  end
end

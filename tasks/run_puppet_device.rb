#!/opt/puppetlabs/puppet/bin/ruby

require 'facter'
require 'json'
require 'open3'
require 'puppet'
require 'puppet/ssl/certificate'
require 'puppet/ssl/host'
require 'puppet/util/network_device/config'
require 'timeout'

# Define defaults and read parameters.

default_timeout = 64
params = JSON.parse(STDIN.read)
noop = (params['_noop']) ? '--noop' : ''
target = (params['target']) ? params['target'] : ''
timeout = (params['timeout'].to_i > 0) ? params['timeout'].to_i : default_timeout
apply = (params['apply']) ? "--apply=#{params['apply']}" : ''

# Validation for apply
if params['apply']
  # Puppet device --apply was released in Puppet 5.5
  if Gem::Version.new(Facter.value(:puppetversion)) < Gem::Version.new('5.5')
    raise("puppet device --apply does not exist in Puppet version: #{Facter.value(:puppetversion)}. --apply was added in Puppet 5.5.")
  end

  unless File.file?(params['apply'])
    raise("Invalid value for parameter 'apply'. #{params['apply']} does not exist.'")
  end
end

# Read all devices, or just the target device.

def read_device_configuration(target)
  Puppet.initialize_settings
  devices = Puppet::Util::NetworkDevice::Config.devices.dup
  if target != ''
    devices.select! { |key, _value| key == target }
  end
  devices
end

# Read a device certificate and return its fingerprints.

def read_device_certificate_fingerprints(cert_name)
  cert_file = File.join(Puppet[:devicedir], cert_name, 'ssl', 'certs', "#{cert_name}.pem")
  if File.file?(cert_file)
    begin
      certificate = Puppet::SSL::Certificate.from_s(Puppet::FileSystem.read(cert_file))
    rescue OpenSSL::X509::CertificateError
      certificate = nil
    end
  end
  return nil unless certificate
  fingerprints = {}
  fingerprints['default'] = certificate.fingerprint
  mdas = if Puppet.respond_to? :valid_digest_algorithms
           Puppet.valid_digest_algorithms
         else
           Puppet::SSL::Host.new.suitable_message_digest_algorithms
         end
  mdas.each do |mda|
    fingerprints[mda.to_s] = certificate.fingerprint(mda)
  end
  fingerprints
end

# Run 'puppet device' for each device, or just the target device.

def run_puppet_device(devices, noop, timeout, apply)
  os = Facter.value(:os) || {}
  osfamily = os['family']
  if osfamily == 'windows'
    env_windows_installdir = Facter.value(:env_windows_installdir) || 'C:\Program Files\Puppet Labs\Puppet'
    puppet_command = %("#{env_windows_installdir}\bin\puppet")
  else
    puppet_command = '/opt/puppetlabs/puppet/bin/puppet'
  end
  # PUP-1391 Puppet 5.4.0 does not require '--user=root'.
  user = (Gem::Version.new(Puppet.version) > Gem::Version.new('5.4.0')) ? '' : '--user=root'
  results = {}
  results['error_count'] = 0

  devices.map do |device_name, _device|
    target = "--target=#{device_name}"
    line = ''
    error_message = ''
    configuration_version = ''
    catalog_seconds = ''
    status = ''
    result = ''

    begin
      Open3.popen2e(puppet_command, 'device', user, '--waitforcert=0', '--verbose', target, noop, apply) do |_, oe, w|
        begin
          Timeout.timeout(timeout) do
            until oe.eof?
              line = oe.readline
              if (matched = line.match(%r{Error: (?<error>.*)}))
                error_message = matched[:error]
              end
              if (matched = line.match(%r{Exiting; (?<certificate>no certificate found and waitforcert is disabled)}))
                error_message = matched[:certificate]
              end
              if (matched = line.match(%r{Applying configuration version '(?<version>.*?)'}))
                configuration_version = matched[:version]
              end
              if (matched = line.match(%r{Applied catalog in (?<seconds>.*?) seconds}))
                catalog_seconds = matched[:seconds]
              end
            end
          end
        rescue Timeout::Error
          Process.kill('KILL', w.pid)
          error_message = 'timeout error'
        end
      end
    rescue => e
      error_message = e.message
    end

    if error_message.empty?
      status = 'success'
      result = "applied configuration version '#{configuration_version}' in #{catalog_seconds} seconds"
    else
      status = 'error'
      result = error_message.gsub(%r{\e\[(\d+)m}, '')
      results['error_count'] = results['error_count'] + 1
    end

    results[device_name] = {}
    fingerprints = read_device_certificate_fingerprints(device_name)
    if fingerprints
      results[device_name]['fingerprint'] = fingerprints['default']
      # Returning all fingerprints obscures other results.
      # results[device_name]['fingerprints'] = fingerprints
    end
    results[device_name]['status'] = status
    results[device_name]['result'] = result
  end

  results
end

# Format a configuration error, and exit.

def return_configuration_error(params)
  result = {}
  device_s = (params['target']) ? "device named [#{params['target']}]" : 'devices'
  result[:_error] = {
    msg: "configuration error: no #{device_s} in #{Puppet[:deviceconfig]}",
    kind: 'puppetlabs/device_manager',
    details: {
      params: {
        noop: params['noop'],
        target: params['target'],
        timeout: params['timeout'],
      },
    },
  }
  puts result.to_json
  exit 1
end

# Format results for all devices, or just the target device, and exit.

def return_results(params, results)
  result = {}
  if results['error_count'] > 0
    exit_code = 1
    error_s = (results['error_count'] == 1) ? 'error' : 'errors'
    result[:_error] = {
      msg: "puppet device run #{error_s}: review task status via the Console",
      kind: 'puppetlabs/device_manager',
      details: {
        params: {
          noop: params['noop'],
          target: params['target'],
          timeout: params['timeout'],
        },
        results: results,
      },
    }
  else
    exit_code = 0
    result['status'] = 'success'
    result['results'] = results
    result['_noop'] = 'true' if params['_noop'] == '--noop'
  end
  puts result.to_json
  exit exit_code
end

# Run this task.

devices = read_device_configuration(target)
if devices.count.zero?
  return_configuration_error(params)
else
  results = run_puppet_device(devices, noop, timeout, apply)
  return_results(params, results)
end

#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'open3'
require 'puppet'
require 'puppet/util/network_device/config'
require 'timeout'

####

default_timeout = 64
params = JSON.parse(STDIN.read)
noop = (params['_noop']) ? '--noop' : ''
target = (params['target']) ? params['target'] : ''
timeout = (params['timeout'].to_i > 0) ? params['timeout'].to_i : default_timeout

####

# def safe_target(target)
#  (target =~ %r{^[a-z0-9._-]+$}) == 0
# end

#

def read_device_config(target)
  Puppet.initialize_settings
  devices = Puppet::Util::NetworkDevice::Config.devices.dup
  if target != ''
    devices.select! { |key, _value| key == target }
  end
  devices
end

#

def run_puppet_device(devices, noop, timeout)
  puppet = (%r{mingw} =~ RUBY_PLATFORM) ? '"C:\Program Files\Puppet Labs\Puppet\bin\puppet"' : '/opt/puppetlabs/puppet/bin/puppet'
  results = {}
  results['error_count'] = 0

  devices.collect do |device_name, _device|
    target = "--target=#{device_name}"
    line = ''
    error_message = ''
    configuration_version = ''
    catalog_seconds = ''
    status = ''
    result = ''

    begin
      Open3.popen2e(puppet, 'device', '--user=root', '--waitforcert=0', '-v', target, noop) do |_, oe, w|
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

    error_message.gsub!(%r{\e\[(\d+)m}, '')

    if error_message == ''
      status = 'success'
      result = "applied configuration version '#{configuration_version}' in #{catalog_seconds} seconds"
    else
      status = 'error'
      if error_message == ''
        error_message = "unable to parse the output of the puppet device command: #{error_message}"
      end
      result = error_message
      results['error_count'] = results['error_count'] + 1
    end

    results[device_name] = {
      status: status,
      result: result,
    }
  end

  results
end

#

def return_result_read_device_config_error(params)
  result = {}
  plurality = (params['target']) ? "device named [#{params['target']}]" : 'devices'
  result[:_error] = {
    msg: "configuration error: no #{plurality} in #{Puppet[:deviceconfig]}",
    kind: 'tkishel/puppet_device',
    details: {
      params: {
        noop: params['noop'],
        target: params['target'],
        timeout: params['timeout']
      }
    }
  }
  puts result.to_json
  exit 1
end

#

def return_result(params, results)
  result = {}
  if results['error_count'] > 0
    exit_code = 1
    plurality = (results['error_count'] > 1) ? 's' : ''
    result[:_error] = {
      msg: "puppet device run error#{plurality}: review status via the Console",
      kind: 'tkishel/puppet_device',
      details: {
        params: {
          noop: params['noop'],
          target: params['target'],
          timeout: params['timeout']
        },
        results: results
      }
    }
  else
    exit_code = 0
    result['status'] = 'success'
    result['results'] = results
  end
  puts result.to_json
  exit exit_code
end

####

devices = read_device_config(target)
if devices.count > 0
  results = run_puppet_device(devices, noop, timeout)
  return_result(params, results)
else
  return_result_read_device_config_error(params)
end

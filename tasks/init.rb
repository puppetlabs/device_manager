#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'open3'
require 'puppet'
require 'puppet/util/network_device/config'
require 'timeout'

# Defaults

default_timeout = 64

# Input

args = JSON.parse(STDIN.read)
noop = (args['_noop']) ? '--noop' : ''
target = (args['target']) ? args['target'] : ''
timeout = (args['timeout'].to_i > 0) ? args['timeout'].to_i : default_timeout

# Variables

puppet = (%r{mingw} =~ RUBY_PLATFORM) ? '"C:\Program Files\Puppet Labs\Puppet\bin\puppet"' : '/opt/puppetlabs/puppet/bin/puppet'
command = "#{puppet} device --user=root -v --waitforcert=0 #{noop}"
results = {}
result = {}
exitcode = 0

# Read deviceconfig to identify devices

Puppet.initialize_settings
devices = Puppet::Util::NetworkDevice::Config.devices.dup
# Create device list, optionally limited to a list of one target device
devices.select! { |key, _value| key == target } if target != ''
if devices.empty?
  result[:_error] = {
    msg: "deviceconfig error: unable to find device(s) in #{Puppet[:deviceconfig]}",
    kind: 'tkishel/puppet_device',
    details: {
      params: {
        noop: noop,
        target: target
      }
    }
  }
  exitcode = 1
  puts result.to_json
  exit exitcode
end

# Execute the task

devices.collect do |device_name, _device|
  line = ''
  device_error = ''
  device_version = ''
  device_seconds = ''
  device_status = ''
  device_result = ''

  begin
    Open3.popen2e("#{command} --target #{device_name}") do |_, oe, w|
      begin
        Timeout.timeout(timeout) do
          until oe.eof?
            line = oe.readline
            if (matched = line.match(%r{Error: (?<error>.*)}))
              device_error = matched[:error]
              exitcode = 1
            end
            if (matched = line.match(%r{Applying configuration version '(?<version>.*?)'}))
              device_version = matched[:version]
            end
            if (matched = line.match(%r{Applied catalog in (?<seconds>.*?) seconds}))
              device_seconds = matched[:seconds]
            end
          end
        end
      rescue Timeout::Error
        Process.kill('KILL', w.pid)
        device_error = 'timeout error'
        exitcode = 1
      end
    end
  rescue => e
    device_error = e.message
    exitcode = 1
  end

  device_error.gsub!(%r{\e\[(\d+)m}, '')
  if device_version != '' && device_seconds != '' && device_error == ''
    device_status = 'success'
    device_result = "applied configuration version '#{device_version}' in #{device_seconds} seconds"
  else
    device_status = 'error'
    device_error = 'unable to parse the output of the puppet device command' if device_error == ''
    device_result = device_error
  end

  results[device_name] = {
    status: device_status,
    result: device_result,
  }
end

# Compose the result

if exitcode.zero?
  result['status'] = 'success'
  result['results'] = results
else
  noop.slice! '--'
  target.slice! '--target '
  result[:_error] = {
    msg: 'puppet device error',
    kind: 'tkishel/puppet_device',
    details: {
      params: {
        noop: noop,
        target: target,
        timeout: timeout
      },
      results: results
    }
  }
end

# Return the result

puts result.to_json
exit exitcode

#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'open3'
require 'timeout'

# Constants

default_timeout = 64
device_conf = '/etc/puppetlabs/puppet/device.conf'
puppet = '/opt/puppetlabs/bin/puppet'

# Input

args = JSON.parse(STDIN.read)
noop = (args['_noop']) ? '--noop' : ''
target = (args['target']) ? args['target'] : ''
timeout = (args['timeout'].to_i > 0) ? args['timeout'].to_i : default_timeout

# Variables

command = "#{puppet} device --user=root -v --waitforcert=0 #{noop}"
devices = []
results = {}
result = {}
exitcode = 0

# If target is not specified, read device.conf to identify devices.

if target == ''
  begin
    File.open(device_conf, 'r') do |file|
      file.each_line do |line|
        if (matched = line.match(%r{\[(?<device>.*?)\]}))
          devices << matched[:device]
        end
      end
    end
  rescue => e
    error = e.message
    exitcode = 1
    results['targets'] = {
      result: 'none',
      errors: error.gsub(/\e\[(\d+)m/, '')
    }
  end
else
  devices << target
end

# Run puppet device --target for each device.

devices.each do |device|
  line = ''
  device_error = ''
  device_version = ''
  device_seconds = ''
  device_result = ''

  begin
    Open3.popen2e("#{command} --target #{device}") do |_, oe, w|
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
        device_error = 'puppet device timeout error'
        exitcode = 1
      end
    end
  rescue => e
    device_error = e.message
    exitcode = 1
  end

  if device_version != '' && device_seconds != ''
    device_error  = 'none' if device_error == ''
    device_result = "applied configuration version '#{device_version}' in #{device_seconds} seconds"
  else
    device_error  = 'unable to parse the output of the puppet device command' if device_error == ''
    device_result = 'none'
  end

  results[device] = {
    result: device_result,
    errors: device_error.gsub(/\e\[(\d+)m/, '')
  }
end

# Normalize output.

if exitcode.zero?
  result['results'] = results
else
  noop.slice! '--'
  target.slice! '--target '
  result[:_error] = {
    msg: 'task error',
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

puts result.to_json
exit exitcode

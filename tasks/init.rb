#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'open3'
require "timeout"

# Constants

default_timeout = 64

device_conf = '/etc/puppetlabs/puppet/device.conf'
puppet      = '/opt/puppetlabs/bin/puppet'

args = JSON.parse(STDIN.read)

# Normalize input.

noop    = args['_noop']        ? '--noop'             : ''
target  = args['target']       ? args['target']       : ''
timeout = args['timeout'].to_i ? args['timeout'].to_i : default_timeout

command  = "#{puppet} device --user=root -v --waitforcert=0 #{noop}"

target_devices = []
results        = {}
result         = {}
exitcode       = 0

# If target is not specified, read device.conf.

if target == ''
  begin
    File.open(device_conf, 'r') do |file|
      file.each_line do |line|
        if matched = line.match(/\[(?<device>.*?)\]/)
          target_devices << matched[:device]
        end
      end
    end
  rescue Exception => e
    error = e.message
    exitcode = 1
    results['device.conf'] = {
      result: 'none',
      errors: error,
    }
    end
else
  target_devices << target
end

# Run puppet device --target.

target_devices.each do |target_device|

  line = ''
  target_device_error    = ''
  target_device_version  = ''
  target_device_seconds  = ''
  target_device_result   = ''

  begin
    Open3.popen2e("#{command} --target #{target_device}") do |i, oe, w|
      begin
        Timeout.timeout(timeout) do
          until oe.eof? do
            line = oe.readline
            if matched = line.match(/Error: (?<error>.*)/)
              target_device_error = matched[:error]
              exitcode = 1
            end
            if matched = line.match(/Applying configuration version '(?<version>.*?)'/)
              target_device_version = matched[:version]
            end
            if matched = line.match(/Applied catalog in (?<seconds>.*?) seconds/)
              target_device_seconds = matched[:seconds]
            end
          end
        end
      rescue Timeout::Error
        Process.kill('KILL', w.pid)
        target_device_error = "puppet device timeout error"
        exitcode = 1
      end
    end
  rescue Exception => e
    target_device_error = e.message
    exitcode = 1
  end

  if target_device_version != '' && target_device_seconds != ''
    target_device_error  = 'none' if target_device_error == ''
    target_device_result = "applied configuration version '#{target_device_version}' in #{target_device_seconds} seconds"
  else
    target_device_error  = 'unable to parse the output of the puppet device command' if target_device_error == ''
    target_device_result = 'none'
  end

  results[target_device] = {
    result: target_device_result,
    errors: target_device_error,
  }
end

# Normalize output.

if exitcode == 0
  result['results'] = results
else
  noop.slice! '--'
  target.slice! '--target '
  result[:_error] = {
    msg:         "task error",
    kind:        "tkishel/puppet_device",
    details: {
      args: {
        noop:    noop,
        target:  target,
        timeout: timeout,
      },
      results: results,
    },
  }
end

puts result.to_json
exit exitcode

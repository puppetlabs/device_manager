#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'device_manager::merge_default' do
  let(:key) { 'credentials' }
  let(:type) { 'cisco_ios' }
  let(:device_with_value) do
    {
      'credentials' => { 'username' => 'admin', 'port' => 11 },
    }
  end
  let(:device_without_value) do
    {
      'credentials' => {},
    }
  end
  let(:defaults) do
    {
      'credentials' => { 'port' => 22 },
    }
  end
  let(:defaults_with_type_defaults) do
    {
      'credentials' => { 'port' => 33 },
      'cisco_ios'   => { 'credentials' => { 'port' => 44 } },
    }
  end

  context 'when specified: value, global default, not specified: type default, type' do
    it {
      is_expected.to run.with_params(key, device_with_value, defaults).and_return('username' => 'admin', 'port' => 11)
    }
  end
  context 'when specified: global default, not specified: value, type default, type' do
    it {
      is_expected.to run.with_params(key, device_without_value, defaults).and_return('port' => 22)
    }
  end
  context 'when specified: type default, global default, type, not specified: value' do
    it {
      is_expected.to run.with_params(key, device_without_value, defaults_with_type_defaults, type).and_return('port' => 44)
    }
  end
end

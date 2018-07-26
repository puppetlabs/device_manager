#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'device_manager::value_or_default' do
  let(:key) { 'run_interval' }
  let(:type) { 'cisco_ios' }
  let(:device_with_value) do
    {
      'run_interval' => 11,
    }
  end
  let(:device_without_value) do
    {
    }
  end
  let(:defaults) do
    {
      'run_interval' => 22,
    }
  end
  let(:defaults_with_type_defaults) do
    {
      'run_interval' => 33,
      'cisco_ios'    => { 'run_interval' => 44 },
    }
  end

  context 'when specified: value, global default, not specified: type default, type' do
    it {
      is_expected.to run.with_params(key, device_with_value, defaults).and_return(11)
    }
  end
  context 'when specified: value, type default, global default, not specified: type' do
    it {
      is_expected.to run.with_params(key, device_with_value, defaults_with_type_defaults).and_return(11)
    }
  end
  context 'when specified: global default, not specified: value, type default, type' do
    it {
      is_expected.to run.with_params(key, device_without_value, defaults).and_return(22)
    }
  end
  context 'when specified: type default, global default, type, not specified: value' do
    it {
      is_expected.to run.with_params(key, device_without_value, defaults_with_type_defaults, type).and_return(44)
    }
  end
end

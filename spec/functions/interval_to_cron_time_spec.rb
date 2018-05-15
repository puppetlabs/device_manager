#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'device_manager::interval_to_cron_time' do
  context 'when interval is equal to 0' do
    it {
      is_expected.to run.with_params(0, 0).and_return(
        'hour'   => 'absent',
        'minute' => 'absent',
      )
    }
  end

  context 'when interval is equal to 1' do
    it {
      is_expected.to run.with_params(1, 1).and_return(
        'hour'   => '*',
        'minute' => '*',
      )
    }
  end

  context 'when interval is less than 30' do
    it {
      is_expected.to run.with_params(15, 1).and_return(
        'hour'   => '*',
        'minute' => [1, 16, 31, 46],
      )
    }
  end

  context 'when interval is equal to 30' do
    it {
      is_expected.to run.with_params(30, 1).and_return(
        'hour'   => '*',
        'minute' => [1, 31],
      )
    }
  end

  context 'when interval is more than 30 and less than 60' do
    it {
      is_expected.to run.with_params(45, 1).and_return(
        'hour'   => '*',
        'minute' => 1,
      )
    }
  end

  context 'when interval is equal to 60' do
    it {
      is_expected.to run.with_params(60, 1).and_return(
        'hour'   => '*',
        'minute' => 1,
      )
    }
  end

  context 'when interval is greater than 60' do
    it {
      is_expected.to run.with_params(75, 1).and_return(
        'hour'   => '*/2',
        'minute' => 1,
      )
    }
  end
end

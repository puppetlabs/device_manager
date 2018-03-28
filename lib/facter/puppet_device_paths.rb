Facter.add('puppet_settings_deviceconfig') do
  setcode do
    Puppet.settings['deviceconfig']
  end
end

Facter.add('puppet_settings_confdir') do
  setcode do
    File.dirname(Puppet.settings['confdir'])
  end
end

Facter.add('puppet_settings_confdir') do
  confine :osfamily => :windows
  setcode do
    File.dirname(File.dirname(Puppet.settings['confdir']))
  end
end

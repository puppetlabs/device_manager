Facter.add('puppet_deviceconfig') do
  setcode do
    Puppet.settings['deviceconfig']
  end
end

Facter.add('puppetlabs_confdir') do
  setcode do
    File.dirname(Puppet.settings['confdir'])
  end
end

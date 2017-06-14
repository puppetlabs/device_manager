Facter.add('puppet_deviceconfig') do
  setcode do
    Puppet.settings['deviceconfig']
  end
end

Facter.add('puppetlabs_confdir') do
  setcode do
    puppet_confdir = Puppet.settings['confdir']
    puppetlabs_confdir = File.dirname(puppet_confdir)
  end
end

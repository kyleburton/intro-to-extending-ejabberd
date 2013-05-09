name             'packages'
maintainer       'eng@relaynetwork.com'
maintainer_email 'eng@relaynetwork.com'
license          'All rights reserved'
description      'Installs/Configures packages'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{apt}.each do |d|
  depends d
end

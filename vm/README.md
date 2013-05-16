
Add the following to your ~/.ssh/config

    Host ejabberd01
      Hostname 127.0.0.1
      User vagrant
      Port 2222
      IdentityFile /Users/kburton/.vagrant.d/insecure_private_key
    
    Host ejabberd02
      Hostname 127.0.0.1
      User vagrant
      Port 2200
      IdentityFile /Users/kburton/.vagrant.d/insecure_private_key
    
    

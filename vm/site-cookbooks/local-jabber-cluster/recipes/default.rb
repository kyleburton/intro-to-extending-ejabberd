local_jabber_cluster_config = node['local-jabber-cluster']||[]

user_accounts = (local_jabber_cluster_config['users']||[])
user_accounts << "vagrant"

user_accounts.each do |user|
  name = user['name']
end


`ip addr | grep 10\.1\.0`.first =~ /10\.1\.0\.1(\d)/
nodenum = $1.to_i + 1
ejabberd_hostname = "ejabberd0#{nodenum}"

template "/etc/hosts" do
  source "hosts.erb"
  mode 644
  variables(
    :hostname => ejabberd_hostname
  )
end

file "/etc/hostname" do
  content ejabberd_hostname
  mode 644
end

bash "set hosntame to #{ejabberd_hostname}" do
  code "hostname --file /etc/hostname"
end

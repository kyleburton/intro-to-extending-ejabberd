local_jabber_cluster_config = node['local-jabber-cluster']||[]

user_accounts = (local_jabber_cluster_config['users']||[])
mod_rest_api_key = local_jabber_cluster_config['api_key']||"52536c88-bf2b-11e2-b8c1-60c547986f44"

# NB: this is available from ohai somewhere, we should have used it instead
# detect which jabber node we are
`ip addr | grep 10\.1\.0`.first =~ /10\.1\.0\.1(\d)/
nodenum = $1.to_i + 1
ejabberd_hostname = "ejabberd0#{nodenum}"

user_accounts << "vagrant"
user_accounts.each do |user|
  name = user['name']
end

# NB: this must match what is in the Vagrantfile
jabber_node_config = {
  'ejabberd01' => {
    :hosts => ["10.1.0.11 ejabberd02"],
    :node_name => 'ejabberd01'
  },
  'ejabberd02' => {
    :hosts => ["10.1.0.10 ejabberd01"],
    :node_name => 'ejabberd02'
  }
}


template "/etc/hosts" do
  source "hosts.erb"
  mode 644
  variables(
    :hostname                 => ejabberd_hostname,
    :other_jabber_hostentries => jabber_node_config[ejabberd_hostname][:hosts]
  )
end

file "/etc/hostname" do
  content ejabberd_hostname
  mode 644
end

bash "set hosntame to #{ejabberd_hostname}" do
  code "hostname --file /etc/hostname"
end

file "/usr/local/ejabberd-2.1.12/var/lib/ejabberd/.erlang.cookie" do 
  owner   "ejabberd"
  group   "ejabberd"
  mode    0600
  content "OUBAPPEQHDVXFCKCAEYN"
end

template "/usr/local/ejabberd-2.1.12/etc/ejabberd/ejabberd.cfg" do
  source "ejabberd.cfg.erb"
  mode 0644
  variables(
    :api_key => mod_rest_api_key
  )
end

template "/usr/local/ejabberd-2.1.12/etc/ejabberd/ejabberdctl.cfg" do
  source "ejabberdctl.cfg.erb"
  mode 0644
  variables(
    :api_key   => mod_rest_api_key,
    :node_name => jabber_node_config[ejabberd_hostname][:node_name]
  )
end


bash "git clone https://github.com/kyleburton/intro-to-extending-ejabberd.git" do
  user "vagrant"
  group "vagrant"
  cwd "/home/vagrant"
  code <<-END
  test -d projects || mkdir projects
  cd projects
  test -d intro-to-extending-ejabberd || git clone https://github.com/kyleburton/intro-to-extending-ejabberd.git
END
end

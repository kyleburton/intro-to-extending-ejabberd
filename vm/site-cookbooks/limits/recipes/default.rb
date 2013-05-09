#
# Cookbook Name:: limits
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template node['limits']['limits.conf'] do
  source 'limits.conf.erb'
  mode '0644'
end


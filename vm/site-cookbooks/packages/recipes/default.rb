#
# Cookbook Name:: packages
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "apt-get update for packages" do
  code "apt-get update -y"
end

(node['packages']||[]).each do |pkg|
  package pkg do 
    action :install
  end
end

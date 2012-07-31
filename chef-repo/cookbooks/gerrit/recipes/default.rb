#
# Cookbook Name:: gerrit
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "postgresql::server"

node.default['gerrit']['war_file'] = File.basename(node['gerrit']['url'])
node.default['gerrit']['war_path'] = File.join(node['gerrit']['path'], node['gerrit']['war_file'])

directory node['gerrit']['path'] do
  owner "root"
  mode "0755"
end

remote_file node['gerrit']['war_path'] do
  source node['gerrit']['url']
  owner "root"
  mode "0644"
  checksum node['gerrit']['sha256']
end




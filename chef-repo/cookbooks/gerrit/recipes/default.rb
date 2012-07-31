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
node.default['gerrit']['bouncy_castle_war_path'] = File.join(node['gerrit']['site_path'], "lib", File.basename(node['gerrit']['bouncy_castle_url']))
node.default['gerrit']['canonical_url'] = "http://#{node['ipaddress']}:#{node['gerrit']['http_port']}/"

directory node['gerrit']['path'] do
  owner "root"
  mode "0755"
end

user node['gerrit']['username'] do
  home node['gerrit']['site_path']
  system true
end

directory node['gerrit']['site_path'] do
  owner node['gerrit']['username']
end

remote_file node['gerrit']['war_path'] do
  source node['gerrit']['url']
  owner "root"
  mode "0644"
  checksum node['gerrit']['sha256']
end

postgresql_database_user node['gerrit']['username'] do
  connection ({:host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']})
  password node['gerrit']['db_password'] 
end

postgresql_database node['gerrit']['db_name'] do
  connection ({:host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']})
  encoding 'UTF-8'
  owner node['gerrit']['username']
end

execute "java -jar #{node['gerrit']['war_path']} init -d #{node['gerrit']['site_path']} --batch" do
  user node['gerrit']['username']
  not_if { File.directory?(File.join(node['gerrit']['site_path'], "bin")) }
end

remote_file node['gerrit']['bouncy_castle_war_path'] do
  source node['gerrit']['bouncy_castle_url']
  owner "root"
  mode "0644"
  checksum node['gerrit']['bouncy_castle_sha256']
end

template File.join(node['gerrit']['site_path'], 'etc', 'gerrit.config') do
  source "gerrit.config.erb"
  owner "root"
  mode "0644"
end

template File.join(node['gerrit']['site_path'], 'etc', 'secure.config') do
  source "secure.config.erb"
  owner "gerrit2"
  mode "0600"
end

file "/etc/default/gerritcodereview" do
  owner "root"
  mode "0644"
  content <<EOH
GERRIT_SITE=#{node['gerrit']['site_path']}
EOH
end


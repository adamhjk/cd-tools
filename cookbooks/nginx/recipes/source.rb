#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2009-2012, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


nginx_url = node['nginx']['source']['url'] ||
  "http://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"

unless(node['nginx']['source']['prefix'])
  node.set['nginx']['source']['prefix'] = "/opt/nginx-#{node['nginx']['version']}"
end
unless(node['nginx']['source']['conf_path'])
  node.set['nginx']['source']['conf_path'] = "#{node['nginx']['dir']}/nginx.conf"
end
unless(node['nginx']['source']['default_configure_flags'])
  node.set['nginx']['source']['default_configure_flags'] = [
    "--prefix=#{node['nginx']['source']['prefix']}",
    "--conf-path=#{node['nginx']['dir']}/nginx.conf"
  ]
end
node.set['nginx']['binary']          = "#{node['nginx']['source']['prefix']}/sbin/nginx"
node.set['nginx']['daemon_disable']  = true

include_recipe "nginx::ohai_plugin"
include_recipe "build-essential"

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/nginx-#{node['nginx']['version']}.tar.gz"
packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  )

packages.each do |devpkg|
  package devpkg
end

remote_file nginx_url do
  source nginx_url
  path src_filepath
  backup false
end

user node['nginx']['user'] do
  system true
  shell "/bin/false"
  home "/var/www"
end

node.run_state['nginx_force_recompile'] = false
node.run_state['nginx_configure_flags'] = 
  node['nginx']['source']['default_configure_flags'] | node['nginx']['configure_flags']

node['nginx']['source']['modules'].each do |ngx_module|
  include_recipe "nginx::#{ngx_module}"
end

configure_flags = node.run_state['nginx_configure_flags']
nginx_force_recompile = node.run_state['nginx_force_recompile']

bash "compile_nginx_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    cd nginx-#{node['nginx']['version']} && ./configure #{node.run_state['nginx_configure_flags'].join(" ")}
    make && make install
    rm -f #{node['nginx']['dir']}/nginx.conf
  EOH
  
  not_if do
    nginx_force_recompile == false &&
      node.automatic_attrs['nginx']['version'] == node['nginx']['version'] &&
      node.automatic_attrs['nginx']['configure_arguments'].sort == configure_flags.sort
  end
end

node.run_state.delete(:nginx_configure_flags)
node.run_state.delete(:nginx_force_recompile)

case node['nginx']['init_style']
when "runit"
  node.set['nginx']['src_binary'] = node['nginx']['binary']
  include_recipe "runit"

  runit_service "nginx"

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    reload_command "[[ -f #{node['nginx']['pid']} ]] && kill -HUP `cat #{node['nginx']['pid']}` || true"
  end
when "bluepill"
  include_recipe "bluepill"

  template "#{node['bluepill']['conf_dir']}/nginx.pill" do
    source "nginx.pill.erb"
    mode 0644
    variables(
      :working_dir => node['nginx']['source']['prefix'],
      :src_binary => node['nginx']['binary'],
      :nginx_dir => node['nginx']['dir'],
      :log_dir => node['nginx']['log_dir'],
      :pid => node['nginx']['pid']
    )
  end

  bluepill_service "nginx" do
    action [ :enable, :load ]
  end

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    reload_command "[[ -f #{node['nginx']['pid']} ]] && kill -HUP `cat #{node['nginx']['pid']}` || true"
    action :nothing
  end
else
  node.set['nginx']['daemon_disable'] = false
  
  template "/etc/init.d/nginx" do
    source "nginx.init.erb"
    owner "root"
    group "root"
    mode "0755"
    variables(
      :working_dir => node['nginx']['source']['prefix'],
      :src_binary => node['nginx']['binary'],
      :nginx_dir => node['nginx']['dir'],
      :log_dir => node['nginx']['log_dir'],
      :pid => node['nginx']['pid']
    )
  end

  template "/etc/sysconfig/nginx" do
    source "nginx.sysconfig.erb"
    owner "root"
    group "root"
    mode "0644"
  end

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action :enable
  end
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

include_recipe 'nginx::commons'

cookbook_file "#{node['nginx']['dir']}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, 'service[nginx]', :immediately
end

service "nginx" do
  action :start
end

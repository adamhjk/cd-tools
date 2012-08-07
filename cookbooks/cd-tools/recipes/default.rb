#
# Cookbook Name:: cd-tools
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "jenkins"

# create up to 10 backups of the files, set the files owner different from the directory.
remote_directory "/var/lib/jenkins/tools" do
  source "tools"
  files_backup 10
  files_owner "root"
  files_mode "0755"
  owner "root"
  mode "0755"
end

# Drop off the jenkins configuration files

template "/var/lib/jenkins/config.xml" do
  source "config.xml.erb"
  owner "jenkins"
  group "jenkins"
  mode "0644"
end

cookbook_file "/var/lib/jenkins/plugins/gerrit-trigger.hpi" do
  source "gerrit-trigger.hpi"
  owner "jenkins"
  group "jenkins"
  mode "0644"
end

template "/var/lib/jenkins/gerrit-trigger.xml" do
  source "gerrit-trigger.xml.erb"
  owner "jenkins"
  group "jenkins"
  mode "0644"
end

template "/var/lib/jenkins/hudson.plugins.warnings.WarningsPublisher.xml" do
  source "hudson.plugins.warnings.WarningsPublisher.xml.erb"
  owner "jenkins"
  group "jenkins"
  mode "0644"
end

search(:chef_pipelines, "*:*") do |pipeline|
  %w{check-syntax check-foodcritic gate-syntax gate-chef-sync"}.each do |job_partial|
    job_directory = "/var/lib/jenkins/jobs/#{pipeline['id']}-#{job_partial}"

    directory job_directory do
      owner "jenkins"
      group "jenkins"
      mode "0755"
      recursive true
    end
    
    template File.join(job_directory, "config.xml") do
      source "#{job_partial}.xml.erb"
      owner "jenkins"
      group "jenkins"
      mode "0644"
      notifies :restart, "service[jenkins]"
      variables(:job => job_partial)
    end
  end
end

#
# Cookbook Name:: cd-tools
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


# create up to 10 backups of the files, set the files owner different from the directory.
remote_directory "/var/lib/jenkins/tools" do
  source "tools"
  files_backup 10
  files_owner "root"
  files_mode "0755"
  owner "root"
  mode "0755"
end


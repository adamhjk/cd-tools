#!/usr/bin/ruby

require 'chef/environment'
require 'chef/data_bag'
require 'chef/data_bag_item'
require 'chef'

Chef::Config.from_file(File.expand_path(File.join(File.dirname(__FILE__), "..", ".chef", "knife.rb")))
binary_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "./build/debs/binaries"))

environment_name = ARGV[0]
app_name = ARGV[1]
build_id = ENV['PARENT_BUILD_ID']

packages = {}
ENV['DEB_PKGS'].split(" ").each do |deb_path|
  package_file = File.basename(deb_path)
  package_file =~ /^(.+)_(.+)_(.+)\.deb/
  package_name = $1
  package_version = $2
  package_architecture = $3
  packages[package_name] = package_version
end

# Accept that the data bag might already exist, so the save returns a 409
begin
  repo_app_db = Chef::DataBag.new
  repo_app_db.name "repo_#{app_name}"
  repo_app_db.save
rescue Net::HTTPServerException => e
  raise e unless e.response.code == "409"
end

repo_app_release = Chef::DataBagItem.new
repo_app_release.data_bag "repo_#{app_name}"
repo_app_release["id"] = build_id
repo_app_release["build_url"] = ENV['PARENT_BUILD_URL']
repo_app_release["gerrit_change_url"] = ENV['PARENT_GERRIT_CHANGE_URL']
repo_app_release["packages"] = packages
repo_app_release.save

# Update the environment after the data bag goes up
to = Chef::Environment.load(environment_name)
puts to.inspect
to.override_attributes["apps"] ||= {}
to.override_attributes["apps"][app_name] ||= {}
to.override_attributes["apps"][app_name]["desired"] = build_id
to.save


#!/usr/bin/ruby
#
# Pin a given environment to the cookbook revisions in the current repository
#

require 'chef/environment'
require 'chef'

Chef::Config.from_file(File.expand_path(File.join(File.dirname(__FILE__), "..", ".chef", "knife.rb")))

def pin_env(env, cookbook_versions)
  to = Chef::Environment.load(env)
  cookbook_versions.each do |cb, version|
    to.cookbook_versions[cb] = version
  end
  to.save
end

cookbook_versions = {}

Dir["#{Chef::Config[:cookbook_path]}/*"].each do |cookbook|
  next unless File.directory?(cookbook)
  metadata_file = File.expand_path(File.join(cookbook, "metadata.rb"))
  File.read(metadata_file).each_line do |line|
    if line =~ /^version\s+["'](\d+\.\d+\.\d+)["'].*$/
      cookbook_versions[File.basename(cookbook)] = "= #{$1}"
    end
  end
end

if ARGV[1] == "integration"
  Chef::Environment.list.each do |env, uri|
    if env != ARGV[0] && env =~ /^(dev-|integration)/
      pin_env(env, cookbook_versions) 
    end 
  end
else
  pin_env(ARGV[0], cookbook_versions)
end

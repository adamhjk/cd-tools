#!/usr/bin/ruby
#
# Takes fragments of environment data and slams them into a given environment 
#

require 'chef/environment'
require 'chef'

Chef::Config.from_file(File.expand_path(File.join(File.dirname(__FILE__), "..", ".chef", "knife.rb")))

def set_env_attrs(to, fragment_file)
  if File.exists?(fragment_file)
    fragment_data = Chef::JSONCompat.from_json(IO.read(fragment_file))
    fragment_data["default_attributes"].each do |k,v|
      to.default_attributes[k] = v
    end
    fragment_data["override_attributes"].each do |k,v|
      to.override_attributes[k] = v
    end
  end
end

environment_name = ARGV[0]
fragment_file = File.expand_path(File.join(File.dirname(__FILE__), "..", "environment_fragments", "#{environment_name}.json")) 

if ARGV[1] == "integration"
  patchset = Chef::Environment.load(environment_name).override_attributes["chef_repo"][environment_name]
  Chef::Environment.list.each do |env, uri|
    if env != environment_name && env =~ /^(dev-|integration)/
      to = Chef::Environment.load(env)
      set_env_attrs(to, fragment_file) 
      to.override_attributes["chef_repo"] ||= {}
      to.override_attributes["chef_repo"][environment_name] = patchset
      to.save
    end 
  end
else
  to = Chef::Environment.load(environment_name)
  set_env_attrs(to, fragment_file)
  to.override_attributes["chef_repo"][environment_name] = { "project" => ENV['GERRIT_PROJECT'],
                                                            "revision" => ENV['GERRIT_PATCHSET_REVISION'] }
  to.save
end


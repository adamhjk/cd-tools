#!/usr/bin/ruby
#
# Takes fragments of environment data and slams them into a given environment 
#

require 'chef/environment'
require 'chef'

Chef::Config.from_file(File.expand_path(File.join(File.dirname(__FILE__), "..", ".chef", "knife.rb")))

environment_name = ARGV[0]

patchset = Chef::Environment.load(environment_name).override_attributes["chef_repo"][environment_name]

patchset.each do |var, val|
    puts "#{var}=#{val}"
end

#
# Cookbook Name:: foodcritic
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "build-essential"

package "libxml2-devel"
package "libxslt-devel"

gem_package "foodcritic" do
  gem_binary "/opt/chef/embedded/bin/gem"
end


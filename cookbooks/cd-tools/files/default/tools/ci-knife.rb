current_dir = File.dirname(ENV['WORKSPACE'])

FileUtils.mkdir_p(File.expand_path(File.join(current_dir, ".ci", "checksums")))

log_level                :info
log_location             STDOUT
node_name                ENV['NODE_NAME'] 
client_key               ENV['CLIENT_KEY']
chef_server_url          ENV['CHEF_SERVER_URL']
cache_type               'BasicFile'
cache_options( :path => "#{current_dir}/.ci/checksums" )
if File.exists?(File.join(ENV['WORKSPACE'], "chef-repo"))
  cookbook_path            ["#{ENV['WORKSPACE']}/chef-repo/cookbooks"]
else
  cookbook_path            ["#{ENV['WORKSPACE']}/cookbooks"]
end

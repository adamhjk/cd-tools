current_dir = File.dirname(__FILE__)

FileUtils.mkdir_p(File.expand_path(File.join(current_dir, ".ci", "checksums")))

log_level                :info
log_location             STDOUT
node_name                ENV['NODE_NAME'] 
client_key               ENV['CLIENT_KEY']
chef_server_url          ENV['CHEF_SERVER_URL']
cache_type               'BasicFile'
cache_options( :path => "#{current_dir}/.ci/checksums" )
cookbook_path            ["#{current_dir}/cookbooks"]

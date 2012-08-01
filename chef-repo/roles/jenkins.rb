name "jenkins"
description "Jenkins Server"
run_list [ "recipe[yum]", "recipe[build-essential]", "recipe[nginx::source]", "recipe[java]", "recipe[jenkins]", "recipe[jenkins::cd]", "recipe[postgresql::server]", "recipe[gerrit]" ]
default_attributes(
  'jenkins' => {
    'http_proxy' => {
      'host_name' => "jenkins.local",
      'variant' => 'nginx'
    },
    'server' => {
      'plugins' => [ 'git', 'gerrit-trigger', 'build-pipeline-plugin', 'github', 'greenballs', 'analysis-core', 'warnings' ]
    }
  },
  'gerrit' => {
    'http_proxy' => {
      'host_name' => "review.local"
    },
    'canonical_url' => "http://review.local/"
  }
)

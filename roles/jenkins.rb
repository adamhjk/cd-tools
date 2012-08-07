name "jenkins"
description "Jenkins Server"
run_list [ "recipe[yum]", "recipe[build-essential]", "recipe[nginx::source]", "recipe[java]", "recipe[jenkins]", "recipe[postgresql::server]", "recipe[gerrit]", "recipe[foodcritic]", "recipe[cd-tools]" ]
default_attributes(
  'build_essential' => {
    'compiletime' => true
  },
  'jenkins' => {
    'http_proxy' => {
      'host_name' => "jenkins.local",
      'variant' => 'nginx'
    },
    'server' => {
      'plugins' => [ 'git', 'build-pipeline-plugin', 'github', 'greenballs', 'analysis-core', 'warnings', 'parameterized-trigger' ]
    }
  },
  'gerrit' => {
    'http_proxy' => {
      'host_name' => "review.local"
    },
    'canonical_url' => "http://review.local/"
  },
  'cd-tools' => {
    'gerrit' => {
      'hostname' => "review.local",
      'front_end_url' => "http://review.local/"
    }
  }
)

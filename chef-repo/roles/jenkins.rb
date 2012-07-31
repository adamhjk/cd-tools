name "jenkins"
description "Jenkins Server"
run_list [ "recipe[yum]", "recipe[build-essential]", "recipe[java]", "recipe[jenkins]", "recipe[postgresql::server]", "recipe[gerrit]" ]

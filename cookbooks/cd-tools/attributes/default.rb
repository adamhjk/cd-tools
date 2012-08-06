default["cd-tools"]["gerrit"]["hostname"] = node['fqdn']
default["cd-tools"]["gerrit"]["ssh_port"] = 29418
default["cd-tools"]["gerrit"]["username"] = 'jenkins'
default["cd-tools"]["gerrit"]["auth_key_file"] = '/var/lib/jenkins/.ssh/id_rsa'
default["cd-tools"]["gerrit"]["front_end_url"] = "http://#{node['fqdn']}"



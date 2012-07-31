
%w{git gerrit-trigger build-pipeline-plugin github greenballs}.each do |plugin|
  jenkins_cli "install-plugin #{plugin}"
end
jenkins_cli "safe-restart"


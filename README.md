cd-tools
========

cd tools!

are the bestest

------
gerrit
------

OK - the recipe will get you set up, but there are manual steps. You need to log in to the review system, and register the first user.

Add an ssh key, select a username.

Manipulate the default permissions.

Admin->Project->All-Projects->Access

  refs/*
    + Read -> Non-Interactive Users
    + Push -> Administrators -> Force Push Checked
    + Create References -> Administrators
  refs/heads/*
    + Push -> Administrators -> Force Push Checked
    + Label Verified -> Non-Interactive Users (-1/+1)
    + Label Code Reviewed -> Non-Interactive Users (-1/+1)

# Add the gerrit user

  cat /var/lib/jenkins/.ssh/id_rsa.pub | ssh -p29418 adam@review.local gerrit create-account --ssh-key - --full-name Jenkins jenkins

Add the Jenkins suer to the Non-Interactive Users group

# Creating a repository

Admin->Projects->Create New Project
Name: SHould match the upstream github repo
Rights Inherit From: All-Projects

In the project itself

  Merge if neccessary
  Automatically resolve conflicts
  Require Change ID
  (If it's open source, add the signed-off-by)


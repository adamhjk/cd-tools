cd-tools
========

cd tools!

are the bestest

------
gerrit
------

OK - the recipe will get you set up, but there are manual steps. You need to log in to the review system, and register the first user.

# Add an ssh key, select a username.

# Add the gerrit user

  cat /var/lib/jenkins/.ssh/id_rsa.pub | ssh -p29418 adam@review.local gerrit create-account --ssh-key - --full-name Jenkins jenkins

# Add the Jenkins suer to the Non-Interactive Users group

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
    + Submit -> Registered Users


# Configure gerrit for ssh to github

Make sure you add the ssh host key for git@github.com to gerrit's ssh known hosts, and have restarted gerrit

Configure replication

[remote "github"]
  url = git@github.com:adamhjk/#{name}
  push = +refs/heads/*:refs/heads/*
  push = +refs/tags/*:refs/tags/*

# Creating a repository

Admin->Projects->Create New Project
Name: SHould match the upstream github repo
Rights Inherit From: All-Projects

In the project itself

  Merge if neccessary
  Automatically resolve conflicts
  Require Change ID
  (If it's open source, add the signed-off-by)

# Configure Jenkins

Manage Jenkins->Gerrit Trigger
  
  Hostname: review.local
  Frontend URL: http://review.local
  SSH Port: 29418
  Username: jenkins

# Test Flow for Cookbooks

- Check Jobs
  - Merge
  - Syntax
  - Foodcritic
- Gate Tests
  - Syntax
  - Foodcritic
  - Chef Server Dev Environment Update
- Promotion
  - Dev->Integration
  - Dev->Staging
  - Staging->Production
  - Production->A
  - A->B

# Create the first check job

# Gate Tests


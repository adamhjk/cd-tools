maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures gerrit"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.13"

depends 'nginx'
depends 'git'
depends 'postgresql'
depends 'database'
depends 'git'

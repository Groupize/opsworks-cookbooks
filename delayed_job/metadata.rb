maintainer       "Artsy"
maintainer_email "it@artsymail.com"
license          "MIT"
description      "Configure and deploy background job workers."

recipe 'delayed_job::setup', 'Set up delayed_job worker.'
recipe 'delayed_job::configure', 'Configure delayed_job worker.'
recipe 'delayed_job::deploy', 'Deploy delayed_job worker.'
recipe 'delayed_job::undeploy', 'Undeploy delayed_job worker.'
recipe 'delayed_job::stop', 'Stop delayed_job worker.'

depends 'deploy'

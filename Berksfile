# -*- mode: ruby -*-
# vi: set ft=ruby :
source 'https://supermarket.chef.io'

cookbook 'ubuntu'
cookbook 'apt'
cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall', '~> 2.3.0'
cookbook 'ntp'
cookbook 'sudo'
cookbook 'timezone-ii'

cookbook 'memcached'

group :wrapper do
  cookbook 'w_common', git: 'https://github.com/haapp/w_common.git'
  cookbook 'w_memcached', path: './'
end

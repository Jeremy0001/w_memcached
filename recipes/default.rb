#
# Cookbook Name:: w_memcached
# Recipe:: default
#
# Copyright 2014, Joel Handwell
#
# license apachev2

include_recipe 'memcached'

firewall 'default'

firewall_rule 'memcached' do
  port     11211
end

include_recipe 'w_memcached::monit' if node['monit_enabled']
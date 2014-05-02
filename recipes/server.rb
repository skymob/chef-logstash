# Encoding: utf-8
#
# Author:: John E. Vincent
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, John E. Vincent
# Copyright 2012, Bryan W. Berry
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: server
#
#

# install logstash 'server'

name = 'server'

Chef::Application.fatal!("attribute hash node['logstash']['instance']['#{name}'] must exist.") if node['logstash']['instance'][name].nil?

# these should all default correctly.  listing out for example.
logstash_instance name do
  action            :create
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable]
end

es_ip = service_ip(name, 'elasticsearch')

if node[:logstash][:instance][name].key?('enable_embedded_es')
  embedded_es = node[:logstash][:instance][name][:enable_embedded_es]
else
  embedded_es = node[:logstash][:instance][:default][:enable_embedded_es]
end

my_templates  = {
  'input_syslog' => 'config/input_syslog.conf.erb',
  'output_stdout' => 'config/output_stdout.conf.erb',
  'output_elasticsearch' => 'config/output_elasticsearch.conf.erb'
}

logstash_config name do
  templates my_templates
  action [:create]
  variables(
    elasticsearch_ip: es_ip,
    elasticsearch_embedded: embedded_es
  )
end

logstash_plugins 'contrib' do
  instance name
  action [:create]
end

logstash_pattern name do
  action [:create]
end

logstash_service name do
  action      [:start]
end

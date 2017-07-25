tomcat_home = node['aps-core']['appserver']['tomcat_home']
appserver_username = node['appserver']['username']
appserver_group = node['appserver']['group']

# Probably this can be downloaded in a better way, but at least we are using chef resources.

tmp_activiti_war_path = "#{Chef::Config[:file_cache_path]}/activiti-app.war"
final_activiti_war_path = "#{tomcat_home}/webapps/activiti-app.war"

chosen_action = node['aps-core']['attempt_upgrade'] ? :create : :create_if_missing

remote_file tmp_activiti_war_path do
  source "https://#{node['aps-core']['nexus']['username']}:#{node['aps-core']['nexus']['password']}@artifacts.alfresco.com/nexus/service/local/repositories/activiti-enterprise-releases/content/com/activiti/activiti-app/#{node['aps-core']['version']}/activiti-app-#{node['aps-core']['version']}.war"
  owner appserver_username
  group appserver_group
  mode 00740
  action chosen_action
  retries 2
end

file final_activiti_war_path do
  owner appserver_username
  group appserver_group
  mode 00740
  content lazy { ::File.open(tmp_activiti_war_path).read }
  action chosen_action
end

remote_file "#{tomcat_home}/lib/mysql-connector-java.jar" do
  source node['aps-core']['mysql_driver']['url']
  owner appserver_username
  group appserver_group
  mode 00740
  action chosen_action
  only_if { node['aps-core']['db']['engine'] == 'mysql' }
  retries 2
end

remote_file "#{tomcat_home}/lib/postgresql.jar" do
  source node['aps-core']['postgres_driver']['url']
  owner appserver_username
  group appserver_group
  mode 00740
  action chosen_action
  only_if { node['aps-core']['db']['engine'] == 'postgres' }
  retries 2
end
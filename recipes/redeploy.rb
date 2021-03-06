tomcat_home = node['aps-core']['appserver']['tomcat_home']
service_name = "#{node['appserver']['installname']}-#{node['tomcat']['service']}"

service service_name do
  action :stop
end

include_recipe 'aps-core::_download_artifacts' if node['aps-core']['redownload_apps']

template "#{tomcat_home}/lib/activiti-app.properties" do
  source 'activiti-properties.erb'
  variables(
    lazy do
      { properties: node['aps-core']['activiti-app-properties'] }
    end
  )
end

template "#{tomcat_home}/lib/activiti-admin.properties" do
  source 'activiti-properties.erb'
  variables(
    lazy do
      { properties: node['aps-core']['activiti-admin-properties'] }
    end
  )
  only_if { node['aps-core']['admin_app']['install'] }
end

service service_name do
  action :start
end

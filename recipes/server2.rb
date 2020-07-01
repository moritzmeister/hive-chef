include_recipe "hive2::_configure"

# Template HiveServer2 for the JMX prometheus exporter
cookbook_file "#{node['hive2']['conf_dir']}/hiveserver2.yaml" do
  source 'hiveserver2.yaml'
  owner node['hive2']['user']  
  group node['hive2']['group'] 
  mode '0755'
  action :create
end

deps = ""
if exists_local("ndb", "mysqld") 
  deps = "mysqld.service "
end  
if exists_local("hive2", "metastore") || exists_local("hive2", "default")
  deps += "hivemetastore.service"
end
service_name="hiveserver2"

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/#{service_name}.service"
else
  systemd_script = "/lib/systemd/system/#{service_name}.service"
end

service service_name do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

hive_metastore_fqdn = consul_helper.get_service_fqdn("metastore.hive")

template systemd_script do
  source "#{service_name}.service.erb"
  owner "root"
  group "root"
  mode 0754
  variables({
              :deps => deps,
              :hive_metastore_endpoint => hive_metastore_fqdn
           })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
  end
end

kagent_config service_name do
  action :systemd_reload
end

if node['kagent']['enabled'] == "true"
  kagent_config service_name do
    service "Hive"
    log_file node['hive2']['logs_dir'] + "/hive.log"
  end
end

if conda_helpers.is_upgrade
  kagent_config "#{service_name}" do
    action :systemd_reload
  end
end  

# Register Hive Server with Consul
template "#{node['hive2']['consul']}/hiveserver2-health.sh" do
  source "consul/hive-service-health.sh.erb"
  owner node['hive2']['user']
  group node['hops']['group']
  variables({
    :port => node['hive2']['hs2']['metrics_port']
  })
  mode 0750
end

consul_service "Registering Hive Server2 with Consul" do
  service_definition "consul/hiveserver2-consul.hcl.erb"
  action :register
end

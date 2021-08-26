include_recipe "java"

my_ip = my_private_ip()

group node['hops']['group'] do
  gid node['hops']['group_id']
  action :create
  not_if "getent group #{node['hops']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['hive2']['user'] do
  uid node['hive2']['user_id']
  gid node['hops']['group']
  home node['hive2']['user-home']
  action :create
  shell "/bin/bash"
  manage_home true
  system true
  not_if "getent passwd #{node['hive2']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node["kagent"]["certs_group"] do
  action :manage
  append true
  excluded_members node['hive2']['user']
  not_if { node['install']['external_users'].casecmp("true") == 0 }
  only_if { conda_helpers.is_upgrade }
end

directory node['data']['dir'] do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
  not_if { ::File.directory?(node['data']['dir']) }
end

directory node['hive2']['data_volume']['root_dir'] do
  owner node['hive2']['user']
  group node['hops']['group']
  mode '0775'
end

directory node['hive2']['data_volume']['logs_dir'] do
  owner node['hive2']['user']
  group node['hops']['group']
  mode '0775'
end

package_url = "#{node['hive2']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "#{node['hive2']['user']}"
  mode "0644"
  action :create_if_missing
end

# Extract Hive
hive_downloaded = "#{node['hive2']['home']}/.hive_extracted_#{node['hive2']['version']}"

bash 'extract-hive' do
        user "root"
        group node['hops']['group']
        code <<-EOH
                set -e
                tar zxf #{cached_package_filename} -C /tmp
                mv /tmp/apache-hive-#{node['hive2']['version']}-bin #{node['hive2']['dir']}
                # remove old symbolic link, if any
                rm -f #{node['hive2']['base_dir']}
                ln -s #{node['hive2']['home']} #{node['hive2']['base_dir']}
                chown -R #{node['hive2']['user']}:#{node['hops']['group']} #{node['hive2']['home']}
                chmod 770 #{node['hive2']['home']}
                chown -R #{node['hive2']['user']}:#{node['hops']['group']} #{node['hive2']['base_dir']}
                touch #{hive_downloaded}
                chown -R #{node['hive2']['user']}:#{node['hops']['group']} #{hive_downloaded}
        EOH
     not_if { ::File.exists?( "#{hive_downloaded}" ) }
end


# To make sure that all the custom jars that do not come with the Hive distribution are correctly updated
# during installation/upgrades, we create a separate directory which is cleaned up every time we run this recipe.
directory "#{node['hive2']['hopsworks_jars']}" do 
  recursive true
  action :delete
  only_if { ::Dir.exist?("#{node['hive2']['hopsworks_jars']}") }
end

directory "#{node['hive2']['hopsworks_jars']}" do 
  owner node['hive2']['user']
  group node['hops']['group']
  mode "0755"
  action :create
end

directory "#{node['hive2']['consul']}" do 
  owner node['hive2']['user']
  group node['hops']['group']
  mode "0750"
  action :create
end

# We create a symlink from within hive/lib that points to hive/hopsworks-jars so that all the custom libraries 
# are transparently available without the need of fixing the classpaths.
link "#{node['hive2']['lib_dir']}/hopsworks-jars" do
  to "#{node['hive2']['hopsworks_jars']}"
  link_type :symbolic
end

# Install the mysql-jdbc connector
remote_file "#{node['hive2']['hopsworks_jars']}/mysql-connector-java-#{node['hive2']['mysql_connector_version']}-bin.jar" do
  source node['hive2']['mysql_connector_url']
  checksum node['hive2']['mysql_connector_checksum']
  owner node['hive2']['user']
  group node['hops']['group']
  mode '0755'
  action :create_if_missing
end

# Install the hudi-hadoop-mr-bundle
remote_file "#{node['hive2']['hopsworks_jars']}/hudi-hadoop-mr-bundle-#{node['hive2']['hudi_version']}.jar" do
  source node['hive2']['hudi_hadoop_mr_bundle_url']
  owner node['hive2']['user']
  group node['hops']['group']
  mode '0644'
  action :create_if_missing
end

# Install the prometheus JMX exporter
base_package_filename = File.basename(node['hive2']['jmx']['prometheus_exporter']['url'])
remote_file "#{node['hive2']['hopsworks_jars']}/#{base_package_filename}" do
  source node['hive2']['jmx']['prometheus_exporter']['url']
  owner node['hive2']['user']
  group node['hops']['group']
  mode '0755'
  action :create
end

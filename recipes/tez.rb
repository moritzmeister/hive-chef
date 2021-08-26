# Install Tez
group node['hops']['group'] do
  gid node['hops']['group_id']
  action :create
  not_if "getent group #{node['hops']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['tez']['user'] do
  home "/home/#{node['tez']['user']}"
  uid node['tez']['user_id']
  gid node['hops']['group']
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['tez']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

package_url = "#{node['tez']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "#{node['tez']['user']}"
  mode "0644"
  action :create_if_missing
end

# Extract Tez
tez_downloaded = "#{node['tez']['home']}/.tez_extracted_#{node['tez']['version']}"

bash 'extract-tez' do
        user "root"
        group node['hops']['group']
        code <<-EOH
                set -e
                mkdir /tmp/apache-tez-#{node['tez']['version']}
                tar zxf #{cached_package_filename} -C /tmp/apache-tez-#{node['tez']['version']}
                mv /tmp/apache-tez-#{node['tez']['version']} #{node['tez']['dir']}
                # remove old symbolic link, if any
                rm -f #{node['tez']['base_dir']}
                ln -s #{node['tez']['home']} #{node['tez']['base_dir']}
                chown -R #{node['tez']['user']}:#{node['hops']['group']} #{node['tez']['home']}
                chown -R #{node['tez']['user']}:#{node['hops']['group']} #{node['tez']['base_dir']}
                touch #{tez_downloaded}
                chown -R #{node['tez']['user']}:#{node['hops']['group']} #{tez_downloaded}
        EOH
     not_if { ::File.exists?( "#{tez_downloaded}" ) }
end

hops_hdfs_directory node['tez']['hopsfs_dir'] do
  action :create_as_superuser
  owner node['tez']['user']
  group node['hops']['group']
  mode "1775"
  not_if ". #{node['hops']['home']}/sbin/set-env.sh && #{node['hops']['home']}/bin/hdfs dfs -test -d #{node['tez']['hopsfs_dir']}"
end

hops_hdfs_directory cached_package_filename do
  action :put_as_superuser
  owner node['hops']['hdfs']['user']
  group node['hops']['group']
  dest "#{node['tez']['hopsfs_dir']}/#{base_package_filename}"
  mode "775"
end

# Create configuration file
directory node['tez']['conf_dir'] do
  owner node['tez']['user']
  group node['hops']['group']
end

template "#{node['tez']['conf_dir']}/tez-site.xml" do
  source "tez-site.xml.erb"
  owner node['tez']['user']
  group node['hops']['group']
  mode 0655
end

# Set environment variables
magic_shell_environment 'TEZ_CONF_DIR' do
  value "#{node['tez']['conf_dir']}"
end

magic_shell_environment 'TEZ_JARS' do
  value "#{node['tez']['base_dir']}"
end

magic_shell_environment 'HADOOP_CLASSPATH' do
  value "$HADOOP_CLASSPATH:$TEZ_CONF_DIR:$TEZ_JARS/*:$TEZ_JARS/lib/*"
end

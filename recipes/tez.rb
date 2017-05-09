# Install Tez
group node.tez.group do
  action :create
  not_if "getent group #{node.tez.group}"
end

user node.tez.user do
  home "/home/#{node.tez.user}"
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node.tez.user}"
end

group node.tez.group do
  action :modify
  members ["#{node.tez.user}"]
  append true
end

package_url = "#{node.tez.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "#{node.tez.user}"
  mode "0644"
  action :create_if_missing
end

# Extract Tez
tez_downloaded = "#{node.tez.home}/.tez_extracted_#{node.tez.version}"

bash 'extract-tez' do
        user "root"
        group node.tez.group
        code <<-EOH
                set -e
                mkdir /tmp/apache-tez-#{node.tez.version}
                tar zxf #{cached_package_filename} -C /tmp/apache-tez-#{node.tez.version}
                mv /tmp/apache-tez-#{node.tez.version} #{node.tez.dir}
                # remove old symbolic link, if any
                rm -f #{node.tez.base_dir}
                ln -s #{node.tez.home} #{node.tez.base_dir}
                chown -R #{node.tez.user}:#{node.tez.group} #{node.tez.home}
                chown -R #{node.tez.user}:#{node.tez.group} #{node.tez.base_dir}
                touch #{tez_downloaded}
                chown -R #{node.tez.user}:#{node.tez.group} #{tez_downloaded}
        EOH
     not_if { ::File.exists?( "#{tez_downloaded}" ) }
end

hops_hdfs_directory node.tez.hopsfs_dir do
  action :create_as_superuser
  owner node.tez.user
  group node.tez.group
  mode "1770"
  not_if ". #{node.hops.home}/sbin/set-env.sh && #{node.hops.home}/bin/hdfs dfs -test -d #{node.tez.hopsfs_dir}"
end

bash 'upload-tez-hopsfs' do
  user node.hops.hdfs.user
  group node.hops.group
  code <<-EOH
    #{node.hops.home}/sbin/set-env.sh && #{node.hops.home}/bin/hdfs dfs -copyFromLocal #{cached_package_filename} #{node.tez.hopsfs_dir}
  EOH
  not_if ". #{node.hops.home}/sbin/set-env.sh && #{node.hops.home}/bin/hdfs dfs -test -f #{node.tez.hopsfs_dir}/#{base_package_filename}"
end

# Create configuration file
template "#{node.tez.conf_dir}/tez-site.xml" do
  source "tez-site.xml.erb"
  owner node.tez.user
  group node.tez.group
  mode 0655
end

# Set environment variables
magic_shell_environment 'TEZ_CONF_DIR' do
  owner node.hive2.user
  group node.hive2.group
  value "#{node.tez.conf_dir}"
end

magic_shell_environment 'TEZ_JARS' do
  owner node.hive2.user
  group node.hive2.group
  value "#{node.tez.base_dir}"
end

magic_shell_environment 'HADOOP_CLASSPATH' do
  owner node.hive2.user
  group node.hive2.group
  value "$HADOOP_CLASSPATH:$TEZ_CONF_DIR:$TEZ_JARS/*:$TEZ_JARS/lib/*"
end

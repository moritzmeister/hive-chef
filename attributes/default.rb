include_attribute "kagent"
include_attribute "ndb"
include_attribute "hops"
include_attribute "kzookeeper"

default['hive2']['user']                    = node['install']['user'].empty? ? "hive" : node['install']['user']
default['hive2']['user-home']               = "/home/#{node['hive2']['user']}"
default['hive2']['version']                 = "3.0.0.5"
default['hive2']['url']                     = "#{node['download_url']}/apache-hive-#{node['hive2']['version']}-bin.tar.gz"
default['hive2']['port']                    = "9084"
default['hive2']['portssl']                 = "9085"
default['hive2']['dir']                     = node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['hive2']['home']                    = node['hive2']['dir'] + "/apache-hive-" + node['hive2']['version'] + "-bin"
default['hive2']['base_dir']                = node['hive2']['dir'] + "/apache-hive"
default['hive2']['logs_dir']                = node['hive2']['base_dir'] + "/logs"
default['hive2']['conf_dir']                = node['hive2']['base_dir'] + "/conf"
default['hive2']['lib_dir']                 = node['hive2']['base_dir'] + "/lib"
default['hive2']['hopsworks_jars']          = node['hive2']['base_dir'] + "/hopsworks-jars"
default['hive2']['consul']                  = node['hive2']['base_dir'] + "/consul"
default['hive2']['hopsfs_dir']              = "#{node['hops']['hdfs']['apps_dir']}/hive"
default['hive2']['scratch_dir']             = "/tmp/hive"

default['hive2']['mysql_user']              = "hive"
default['hive2']['mysql_password']          = "hive"
default['hive2']['mysql_connector_version'] = "5.1.29"
default['hive2']['mysql_connector_url']     = "#{node['download_url']}/mysql-connector-java-#{node['hive2']['mysql_connector_version']}-bin.jar"
default['hive2']['mysql_connector_checksum'] = "32ddcf6d2613c79595f4f3fda01efb8620ea2bf50df954215c175ebec4cc67b9"


default['hive2']['metastore']['port']                    = "9083"
default['hive2']['metastore']['enforce_authority']       = "true"
default['hive2']['systemd']                              = "true"

default['hive2']['hopsworks']['port']         = "8080"

default['tez']['user']                    =  node['install']['user'].empty? ? "tez" : node['install']['user']
default['tez']['version']                 = "0.9.1.3"
default['tez']['url']                     = "#{node['download_url']}/apache-tez-#{node['tez']['version']}.tar.gz"
default['tez']['dir']                     =  node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['tez']['home']                    =  node['tez']['dir'] + "/apache-tez-" + node['tez']['version']
default['tez']['base_dir']                =  node['tez']['dir'] + "/apache-tez"
default['tez']['hopsfs_dir']              = "#{node['hops']['hdfs']['apps_dir']}/tez"
default['tez']['conf_dir']                =  node['tez']['base_dir'] + "/conf"

default['slider']['user']                    =  node['install']['user'].empty? ? "slider" : node['install']['user']
default['slider']['version']                 = "0.93.1-incubating-SNAPSHOT"
default['slider']['url']                     = "#{node['download_url']}/slider-#{node['slider']['version']}-all.tar.gz"
default['slider']['dir']                     =  node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['slider']['home']                    =  node['slider']['dir'] + "/apache-slider-" + node['slider']['version']
default['slider']['base_dir']                =  node['slider']['dir'] + "/apache-slider"

default['hive2']['execution_mode']         = "llap"
default['llap']['cluster_name']            = "hops-llap"
default['llap']['execution_mode']          = "none"

default['tez']['session_per_queue']     = 100

default['hive2']['conf']['mapreduce_input_size']     = "134217728"

default['hive2']['hudi_version']              = "0.6.0"
default['hive2']['hudi_hadoop_mr_bundle_url']     = "#{node['download_url']}/hudi/#{node['hive2']['hudi_version']}/hudi-hadoop-mr-bundle-#{node['hive2']['hudi_version']}.jar"

default['hive2']['jmx']['prometheus_exporter']['version']  = "0.12.0"
default['hive2']['jmx']['prometheus_exporter']['url']      = "#{node['download_url']}/prometheus/jmx_prometheus_javaagent-#{node['hive2']['jmx']['prometheus_exporter']['version']}.jar"

default['hive2']['hs2']['metrics_port']                    = "18001"
default['hive2']['hm']['metrics_port']                     = "18002"

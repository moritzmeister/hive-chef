name             "hive2"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Hive Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.0"
source_url       "https://github.com/hopshadoop/hive-chef"


depends 'java', '~> 7.0.0'
depends 'magic_shell', '~> 1.0.0'
depends 'compat_resource', '~> 12.7.3'
depends 'ulimit', '~> 0.4.0'
depends 'authbind', '~> 0.1.10'
depends 'ntp', '~> 2.0.0'


recipe           "install", "Installs a Hive2 Server"
recipe           "default", "Starts both a Hive metastore and server2 and tez"
recipe           "metastore", "Starts  a Hive Metastore Server"
recipe           "server2", "Starts  a Hive Server2"
recipe           "tez", "Install Tez"
recipe           "llap", "Deploy LLAP daemons"
recipe           "purge", "Removes and deletes an installed Hive Server"

attribute "hive2/user",
          :description => "User to install/run as",
          :type => 'string'

attribute "hive2/group",
          :description => "User to install/run as",
          :type => 'string'

attribute "hive2/dir",
          :description => "base dir for installation",
          :type => 'string'

attribute "hive2/version",
          :dscription => "hive version",
          :type => "string"

attribute "hive2/url",
          :dscription => "hive download url",
          :type => "string"

attribute "hive2/port",
          :dscription => "hive.port",
          :type => "string"

attribute "hive2/home",
          :dscription => "hive.home",
          :type => "string"

attribute "hive2/mysql_user",
          :dscription => "mysql user account for hive",
          :type => "string"

attribute "hive2/mysql_password",
          :dscription => "mysql user account for hive",
          :type => "string"

attribute "hive2/metastore/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "hive2/default/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "hive2/server2/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "hive2/metastore/port",
          :description => "metastore port",
          :type => "string"

attribute "hive2/scratch_dir",
          :description => "Hive Tez Scratch dir location",
          :type => "string"

attribute "hive2/conf/mapreduce_input_size",
          :description => "Configure the property: mapreduce.input.fileinputformat.split.minsize - doesn't like units",
          :type => "string"

attribute "install/dir",
          :description => "Set to a base directory under which we will install.",
          :type => "string"

attribute "install/user",
          :description => "User to install the services as",
          :type => "string"

attribute "tez/user",
          :description => "User to install/run tez as",
          :type => 'string'

attribute "slider/user",
          :description => "User to install/run slider as",
          :type => 'string'

attribute "hive2/hudi_hadoop_mr_bundle_url",
          :description => "URL for downloading hudi bundle jar to put in /lib of Hive installation",
          :type => 'string'

attribute "hive2/hudi_version",
          :description => "the hudi version",
          :type => "string"

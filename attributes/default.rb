default['solr']['version'] = "4.1.0"
default['solr']['source_url'] = "http://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
default['solr']['checksum'] = "582ce556a4ba11830fa99451ca0c10695151d694b231fe6c566d0499f79f4c94"

default['solr']['server_dir'] = "/opt/solr"
default['solr']['log_dir'] = "/service/logs"
default['solr']['config_dir'] = "/etc/solr"
default['solr']['data_dir'] = "/var/lib/solr"
default['solr']['stop_port'] = 8079
default['solr']['property_dir'] = '/etc/solr'

default['solr']['user'] = 'root'
default['solr']['group'] = 'root'
default['solr']['install_service'] = true

default['solr']['is_master'] = true
default['solr']['port'] = 8983

default['solr']['zookeeper'] = nil
default['solr']['cores'] = ['product', 'user']

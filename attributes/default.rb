default['solr']['base_url'] = "http://www.fightrice.com/mirrors/apache/lucene/solr/"
default['solr']['version'] = "4.1.0"
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

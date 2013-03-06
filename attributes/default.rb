default['solr']['base_url'] = "http://www.fightrice.com/mirrors/apache/lucene/solr/"
default['solr']['version'] = "4.1.0"
default['solr']['tar_url'] = "#{default['solr']['base_url']}/#{default['solr']['version']}/solr-#{default['solr']['version']}.tgz"
default['solr']['server_dir'] = "/op/solr"
default['solr']['log_dir'] = "/build/logs"

default['solr']['user'] = 'root'
default['solr']['group'] = 'root'

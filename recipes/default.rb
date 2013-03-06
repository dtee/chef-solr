include_recipe "java"

remote_file /tmp/solr.tgz do
	source default['solr']['tar_url']
	mode 00644
	action :create_if_missing
end

bash 'unpack solr' do
	code <<-EOH
		tar xvf /tmp/solr.tgz -C #{node.solr.server_dir}
		touch #{node.solr.server_dir}/.{node.solr.version}
	EOH
	not_if "test -f #{node.solr.server_dir}/.{node.solr.version}"
end

# Create upstart service
template "/etc/init/solr.conf"
	source "solr.conf.erb"
	owner "root"
	group "root"
	variables(
		:server_dir          => node['solr']['server_dir'],
		:log_dir             => node['solr']['log_dir'],
	)
	mode 0744
end

service "solr" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end

include_recipe "java"

tempfile = "/tmp/solr.tgz"

remote_file tempfile do
	source node['solr']['tar_url']
	mode 00644
	action :create_if_missing
end

directory node['solr']['server_dir'] do
	recursive true
	action :create
end

bash 'unpack solr' do
	code <<-EOH
		tar xvf #{tempfile} -C #{node.solr.server_dir}
		touch #{node.solr.server_dir}/.#{node.solr.version}
	EOH
	not_if "test -f #{node.solr.server_dir}/.#{node.solr.version}"
end

# Configure solr

if not node['solr']['cores'].empty?
	directory node['solr']['config_dir'] do
		recursive true
		action :create
	end

	template "#{node.solr.config_dir}/logging.properties" do
		source "logging.properties.erb"
		owner node['solr']['user']
		group node['solr']['group']
		variables(
			:log_dir             => node['solr']['log_dir']
		)
		mode 0644
	end

	template "#{node.solr.config_dir}/solr.xml" do
		source "solr.xml.erb"
		owner node['solr']['user']
		group node['solr']['group']
		variables(
			:cores             => node['solr']['cores']
		)
		mode 0644
	end

	node['solr']['cores'].each do |name|
		directory "#{node.solr.config_dir}/#{name}/conf" do
			owner node['solr']['user']
			group node['solr']['group']
			mode '0644'
			recursive true
		end

		template "#{node.solr.config_dir}/#{name}/conf/schema.xml" do
			source "schema.xml.erb"
			owner node['solr']['user']
			group node['solr']['group']
			variables(
				:name             => name
			)
			mode 0644
		end

		template "#{node.solr.config_dir}/#{name}/conf/solrconfig.xml" do
			source "solrconfig.xml.erb"
			owner node['solr']['user']
			group node['solr']['group']
			variables(
				:name             => name,
				:data_dir         => "#{node.solr.data_dir}/#{name}",
			)
			mode 0644
		end
	end
end

# Create upstart service
template "/etc/init/solr.conf" do
	source "solr.conf.erb"
	owner "root"
	group "root"
	variables(
		:stop_port           => node['solr']['stop_port'],
		:server_dir          => node['solr']['server_dir'],
		:log_dir             => node['solr']['log_dir'],
		:config_dir          => node['solr']['config_dir'],
		:version             => node['solr']['version'],
		:path                => "#{node['solr']['server_dir']}/solr-#{node['solr']['version']}/example",
	)
	mode 0644
end

service "solr" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end

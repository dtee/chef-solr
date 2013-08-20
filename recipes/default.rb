include_recipe "java"

tempfile = "#{Chef::Config['file_cache_path'] || '/tmp'}/solr-#{node['solr']['version']}.tgz"

remote_file tempfile do
	source "#{node['solr']['source_url']}"
	checksum "#{node['solr']['checksum']}"
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

directory "#{node['solr']['log_dir']}" do
  mode 0644
  action :create
end

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

# is current node configured as slave or master
if not node['solr']['property_dir'].nil?
	masterNodes = search(:node, "solr_is_master:true")

	if not masterNodes.empty?
		master = masterNodes[0]
		port = "#{master['solr']['port']}"

		template "#{node['solr']['property_dir']}/solrcore.properties" do
			source "solrcore.properties.erb"
			owner node['solr']['user']
			group node['solr']['group']

			variables(
				:is_master        => node['solr']['is_master'],
				:master_url       => "#{master['fqdn']}:#{port}"
			)

			mode 0644
		end
	end
end

# install solr as upstart service
if node['solr']['install_service']
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
end


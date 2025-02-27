# Cookbook:: kafka
# Provider:: indexer

action :add do
  begin
    parent_config_dir = '/etc/druid'
    config_dir = "#{parent_config_dir}/indexer"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    aws_region = new_resource.aws_region
    
    directory config_dir do
      owner 'root'
      group 'root'
      mode '0755'
    end

    directory log_dir do
      owner user
      group group
      mode '0755'
    end

    #################################
    #################################

    template "#{config_dir}/runtime.properties" do
      source 'indexer.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(name: name, cdomain: cdomain, port: port)
      notifies :restart, 'service[druid-indexer]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source 'log4j2.xml.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(log_dir: log_dir, service_name: suffix_log_dir)
      notifies :restart, 'service[druid-indexer]', :delayed
    end

        # Obtaining s3 data
    begin
      s3 = data_bag_item('passwords', 's3')
    rescue
      s3 = {}
    end

    unless s3.empty?
      s3_bucket = s3['s3_bucket']
      s3_access_key = s3['s3_access_key_id']
      s3_secret_key = s3['s3_secret_key_id']
    end

    template '/etc/sysconfig/druid_indexer' do
      source 'indexer_sysconfig.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(aws_region: aws_region, s3_access_key: s3_access_key, s3_secret_key: s3_secret_key)
      notifies :restart, 'service[druid-indexer]', :delayed
    end

    service 'druid-indexer' do
      supports status: true, start: true, restart: true, reload: true
      action [:enable, :start]
    end

    Chef::Log.info('Druid cookbook (indexer) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service 'druid-indexer' do
      supports status: true, start: true, restart: true, reload: true
      action [:disable, :stop]
    end

    Chef::Log.info('Druid cookbook (indexer) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    ipaddress = new_resource.ipaddress

    unless node['druid']['indexer']['registered']
      query = {}
      query['ID'] = "druid-indexer-#{node['hostname']}"
      query['Name'] = 'druid-indexer'
      query['Address'] = ipaddress
      query['Port'] = 8089
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['router']['registered'] = true
      Chef::Log.info('Druid router service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['druid']['router']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/druid-router-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['router']['registered'] = false
      Chef::Log.info('Druid router service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

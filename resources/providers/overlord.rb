# Cookbook:: kafka
# Provider:: overlord

include Druid::Helper

action :add do
  begin
    parent_config_dir = '/etc/druid'
    config_dir = "#{parent_config_dir}/overlord"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    task_log_dir = "#{log_dir}/indexing"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    s3_bucket = new_resource.s3_bucket
    s3_prefix = new_resource.s3_prefix
    memory_kb = new_resource.memory_kb
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port

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

    directory task_log_dir do
      owner user
      group group
      mode '0755'
    end

    template "#{config_dir}/runtime.properties" do
      source 'overlord.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(name: name, cdomain: cdomain, port: port,
                s3_bucket: s3_bucket, s3_prefix: s3_prefix,
                task_log_dir: task_log_dir)
      notifies :restart, 'service[druid-overlord]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source 'log4j2.xml.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(log_dir: log_dir, service_name: suffix_log_dir)
      notifies :restart, 'service[druid-overlord]', :delayed
    end

    template '/etc/sysconfig/druid_overlord' do
      source 'overlord_sysconfig.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(heap_overlord_memory_kb: memory_kb,
                rmi_address: rmi_address, rmi_port: rmi_port,
                parent_config_dir: parent_config_dir)
      notifies :restart, 'service[druid-overlord]', :delayed
    end

    service 'druid-overlord' do
      supports status: true, start: true, restart: true, reload: true
      action [:enable, :start]
    end

    Chef::Log.info('Druid cookbook (overlord) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    # parent_config_dir = '/etc/druid'
    # config_dir = "#{parent_config_dir}/overlord"
    # parent_log_dir = new_resource.parent_log_dir
    # suffix_log_dir = new_resource.suffix_log_dir
    # ipaddress = new_resource.ipaddress
    # log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    # task_log_dir = "#{log_dir}/indexing"

    service 'druid-overlord' do
      supports status: true, start: true, restart: true, reload: true
      action [:disable, :stop]
    end

    # template_list = [
    #   "#{config_dir}/runtime.properties",
    #   "#{config_dir}/log4j2.xml"
    # ]

    # template_list.each do |temp|
    #   file temp do
    #     action :delete
    #   end
    # end

    # dir_list = [config_dir, task_log_dir, log_dir]

    # dir_list.each do |dir|
    #   directory dir do
    #     recursive true
    #     action :delete
    #   end
    # end

    Chef::Log.info('Druid cookbook (overlord) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    ipaddress = new_resource.ipaddress

    unless node['druid']['overlord']['registered']
      query = {}
      query['ID'] = "druid-overlord-#{node['hostname']}"
      query['Name'] = 'druid-overlord'
      query['Address'] = ipaddress
      query['Port'] = 8084
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['overlord']['registered'] = true
      Chef::Log.info('Druid Overlord service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['druid']['overlord']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/druid-overlord-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['overlord']['registered'] = false
      Chef::Log.info('Druid Overlord service has been deregistered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

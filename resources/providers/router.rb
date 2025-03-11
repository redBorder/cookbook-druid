# Cookbook:: Druid
# Provider:: router

action :add do
  begin
    parent_config_dir = '/etc/druid'
    config_dir = "#{parent_config_dir}/router"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    offheap_router_memory_kb = new_resource.offheap_router_memory_kb
    heap_router_memory_kb = new_resource.heap_router_memory_kb
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

    template "#{config_dir}/runtime.properties" do
      source 'router.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(name: name, cdomain: cdomain, port: port)
      notifies :restart, 'service[druid-router]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source 'log4j2.xml.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(log_dir: log_dir, service_name: suffix_log_dir)
      notifies :restart, 'service[druid-router]', :delayed
    end

    template '/etc/sysconfig/druid_router' do
      source 'router_sysconfig.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(offheap_router_memory_kb: offheap_router_memory_kb, heap_router_memory_kb: heap_router_memory_kb, rmi_address: rmi_address, rmi_port: rmi_port, parent_config_dir: parent_config_dir)
      notifies :restart, 'service[druid-router]', :delayed
    end

    service 'druid-router' do
      supports status: true, start: true, restart: true, reload: true
      action [:enable, :start]
    end

    Chef::Log.info('Druid cookbook (router) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    # parent_config_dir = '/etc/druid'
    # config_dir = "#{parent_config_dir}/indexer"
    # parent_log_dir = new_resource.parent_log_dir
    # suffix_log_dir = new_resource.suffix_log_dir
    # ipaddress = new_resource.ipaddress
    # log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service 'druid-router' do
      supports status: true, start: true, restart: true, reload: true
      action [:disable, :stop]
    end

    # template_list = [
    #  "#{config_dir}/runtime.properties",
    #  "#{config_dir}/log4j2.xml"
    # ]

    # template_list.each do |temp|
    #   file temp do
    #     action :delete
    #   end
    # end

    # dir_list = [config_dir, log_dir]

    # removing directories
    # dir_list.each do |dirs|
    #   directory dirs do
    #     action :delete
    #     recursive true
    #   end
    # end

    Chef::Log.info('Druid cookbook (router) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    ipaddress = new_resource.ipaddress

    unless node['druid']['router']['registered']
      query = {}
      query['ID'] = "druid-router-#{node['hostname']}"
      query['Name'] = 'druid-router'
      query['Address'] = ipaddress
      query['Port'] = 8888
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

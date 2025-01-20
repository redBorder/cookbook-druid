# Cookbook:: kafka
# Provider:: broker
include Druid::Broker

action :add do
  begin
    parent_config_dir = '/etc/druid'
    config_dir = "#{parent_config_dir}/broker"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    processing_threads = new_resource.processing_threads
    http_num_connections = new_resource.http_num_connections
    groupby_max_intermediate_rows = new_resource.groupby_max_intermediate_rows
    groupby_max_results = new_resource.groupby_max_results
    cpu_num = new_resource.cpu_num
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

    #################################
    # Broker resource configuration #
    #################################
    heap_broker_memory_kb = 0

    # Compute the number of processing threads based on CPUs
    processing_threads = cpu_num > 1 ? [ [cpu_num,8].min.to_i-1, 1 ].max : 1 if processing_threads.nil?

    # Compute http server num threads
    http_num_threads = ([ cpu_num-1, 1 ].max * 5)

    # Compute the heap memory, the processing buffer memory and the offheap memory
    heap_broker_memory_kb, processing_memory_buffer_b = compute_memory(memory_kb, processing_threads)
    offheap_broker_memory_kb = (processing_memory_buffer_b * (processing_threads + 1) / 1024).to_i

    # Compute HTTP connection
    http_num_connections = http_num_threads > 1 ? http_num_threads - 5 : 1 if http_num_connections.nil?

    Chef::Log.info(
      "\nBroker Memory:
        * Memory: #{memory_kb}k
        * Heap: #{heap_broker_memory_kb}kb
        * ProcessingBuffer: #{processing_memory_buffer_b / 1024}kb
        * OffHeap: #{offheap_broker_memory_kb}kb"
    )

    #################################
    #################################

    template "#{config_dir}/runtime.properties" do
      source 'broker.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(name: name, cdomain: cdomain, port: port,
                processing_threads: processing_threads, http_num_connections: http_num_connections, http_num_threads: http_num_threads, processing_memory_buffer_b: processing_memory_buffer_b,
                groupby_max_intermediate_rows: groupby_max_intermediate_rows, groupby_max_results: groupby_max_results)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source 'log4j2.xml.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(log_dir: log_dir, service_name: suffix_log_dir)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    template '/etc/sysconfig/druid_broker' do
      source 'broker_sysconfig.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(heap_broker_memory_kb: heap_broker_memory_kb, offheap_broker_memory_kb: offheap_broker_memory_kb,
                rmi_address: rmi_address, rmi_port: rmi_port, parent_config_dir: parent_config_dir)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    service 'druid-broker' do
      supports status: true, start: true, restart: true, reload: true
      action [:enable, :start]
    end

    Chef::Log.info('Druid cookbook (broker) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    # parent_config_dir = '/etc/druid'
    # config_dir = "#{parent_config_dir}/broker"
    # parent_log_dir = new_resource.parent_log_dir
    # suffix_log_dir = new_resource.suffix_log_dir
    # ipaddress = new_resource.ipaddress
    # log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service 'druid-broker' do
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

    Chef::Log.info('Druid cookbook (broker) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    ipaddress = new_resource.ipaddress

    unless node['druid']['broker']['registered']
      query = {}
      query['ID'] = "druid-broker-#{node['hostname']}"
      query['Name'] = 'druid-broker'
      query['Address'] = ipaddress
      query['Port'] = 8080
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['broker']['registered'] = true
      Chef::Log.info('Druid Broker service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['druid']['broker']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/druid-broker-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['broker']['registered'] = false
      Chef::Log.info('Druid Broker service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

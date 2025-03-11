# Cookbook:: druid
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
    num_merge_buffers = new_resource.num_merge_buffers
    memory_kb = new_resource.memory_kb
    heap_indexer_memory_kb = new_resource.heap_indexer_memory_kb
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port
    cpu_num = new_resource.cpu_num
    heap_memory_peon_kb = new_resource.heap_memory_peon_kb
    processing_threads = new_resource.processing_threads
    processing_memory_buffer_b = new_resource.processing_memory_buffer_b
    worker_capacity = new_resource.worker_capacity

    ########################################
    # Indexer resource configuration #
    ########################################

    # reserve indexer heap
    memory_kb -= heap_indexer_memory_kb

    # 1gb per peon heap or 60% of total RAM
    if heap_memory_peon_kb.nil?
      heap_memory_peon_kb = memory_kb > (2 * 1024 * 1024).to_i ? (1 * 1024 * 1024).to_i : (memory_kb * 0.60).to_i
    end

    # Number of min[(cpu - 1),2] or 1
    if processing_threads.nil?
      processing_threads = cpu_num > 1 ? [cpu_num - 1, 2].min : 1
    end

    # Calculate num_merge_buffers
    if num_merge_buffers.nil?
      num_merge_buffers = [ processing_threads / 4, 2 ].max.to_i
    end

    # 256mb per threads or [40% of total RAM / (threads + 1)]
    if processing_memory_buffer_b.nil?
      processing_memory_buffer_b = (memory_kb - heap_memory_peon_kb) > (512 * 1024) * (processing_threads + 1) ? (512 * 1024 * 1024) : ((memory_kb - heap_memory_peon_kb) / (processing_threads + 1)).to_i
    end

    # Worker capacity distributed based on weighted CPU cores across druid-indexer managers
    if worker_capacity.nil?
      total_cores = node['redborder']['managers_per_services']['druid-indexer'].sum do |manager_name|
        node['redborder']['cluster_info'][manager_name]['cpu_cores']
      end
      weighted_capacity = (node['redborder']['druid-indexer-tasks'].to_f * node['cpu']['total'] / total_cores).ceil
      worker_capacity = weighted_capacity.clamp(1, node['redborder']['druid-indexer-tasks'])
    end

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
      source 'indexer.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(worker_capacity: worker_capacity, processing_threads: processing_threads, num_merge_buffers: num_merge_buffers, processing_memory_buffer_b: processing_memory_buffer_b, name: name, cdomain: cdomain, port: port)
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

    begin
      s3 = data_bag_item('passwords', 's3')
    rescue
      s3 = {}
    end

    unless s3.empty?
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
      variables(aws_region: aws_region, s3_access_key: s3_access_key, s3_secret_key: s3_secret_key, rmi_address: rmi_address, rmi_port: rmi_port, heap_indexer_memory_kb: heap_indexer_memory_kb, parent_config_dir: parent_config_dir)
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

      node.normal['druid']['indexer']['registered'] = true
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
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/druid-indexer-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['druid']['indexer']['registered'] = false
      Chef::Log.info('Druid indexer service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

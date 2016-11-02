# Cookbook Name:: kafka
#
# Provider:: historical
#
include Druid::Historical
include Druid::Helper

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/historical"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    segment_cache_dir = new_resource.segment_cache_dir
    memcached_hosts = new_resource.memcached_hosts
    processing_threads = new_resource.processing_threads
    groupby_max_intermediate_rows = new_resource.groupby_max_intermediate_rows
    groupby_max_results = new_resource.groupby_max_results
    disk_size_kb = new_resource.disk_size_kb
    tier = new_resource.tier
    tier_memory_mode = new_resource.tier_memory_mode
    cpu_num = new_resource.cpu_num
    memory_kb = new_resource.memory_kb
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port

     directory config_dir do
      owner "root"
      group "root"
      mode 0755
    end

    directory log_dir do
      owner user
      group group
      mode 0755
    end

    directory segment_cache_dir do
      owner user
      group group
      mode 0755
      recursive true
    end

    #####################################
    # Historical resource configuration #
    #####################################

    # Compute the number of processing threads based on CPUs
    processing_threads = cpu_num > 1 ? cpu_num - 1 : 1 if processing_threads.nil?
    heap_historical_memory_kb, processing_memory_buffer_b = compute_memory(memory_kb, processing_threads)
    offheap_historical_memory_kb = (processing_memory_buffer_b * (processing_threads + 1) / 1024).to_i
    free_memory_kb = heap_historical_memory_kb - offheap_historical_memory_kb - (1024*1024) # This is the overheap.
    segments_memory_b = (free_memory_kb > 0 ? free_memory_kb : 0).to_i * 1024

    max_size_b = 0

    if tier_memory_mode
      max_size_b = segments_memory_b
    else
      max_size_b = disk_size_kb * 1024
    end

    Chef::Log.info(
      "\nHistorical Memory:
        * Memory: #{memory_kb}k
        * Heap: #{heap_historical_memory_kb}kb
        * ProcessingBuffer: #{processing_memory_buffer_b / 1024}kb
        * OffHeap: #{offheap_historical_memory_kb}kb"
    )

    #####################################
    #####################################

    template "#{config_dir}/runtime.properties" do
      source "historical.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port, :memcached_hosts => memcached_hosts,
                :processing_threads => processing_threads, :processing_memory_buffer_b => processing_memory_buffer_b,
                :groupby_max_intermediate_rows => groupby_max_intermediate_rows, :groupby_max_results => groupby_max_results,
                :max_size_b => max_size_b, :tier => tier, :segment_cache_dir => segment_cache_dir)
      notifies :restart, 'service[druid-historical]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source "log4j2.xml.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:log_dir => log_dir, :service_name => suffix_log_dir)
      notifies :restart, 'service[druid-historical]', :delayed
    end

    template "/etc/sysconfig/druid_historical" do
      source "historical_sysconfig.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:heap_historical_memory_kb => heap_historical_memory_kb, :offheap_historical_memory_kb => offheap_historical_memory_kb,
                :rmi_address => rmi_address, :rmi_port => rmi_port)
      notifies :restart, 'service[druid-historical]', :delayed
    end

    service "druid-historical" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action [:enable,:start]
    end

    Chef::Log.info("Druid cookbook (historical) has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/historical"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    segment_cache_dir = new_resource.segment_cache_dir

    service "druid-historical" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action [:disable,:stop]
    end

    template_list = [
      "#{config_dir}/runtime.properties",
      "#{config_dir}/log4j2.xml"
    ]

    template_list.each do |temp|
       file temp do
         action :delete
       end
    end

    dir_list = [
                 config_dir,
                 log_dir,
                 segment_cache_dir
               ]

    # removing directories
    dir_list.each do |dirs|
      directory dirs do
        action :delete
        recursive true
      end
    end

    Chef::Log.info("Druid cookbook (historical) has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :register do
  begin
    if !node["druid"]["historical"]["registered"]
      query = {}
      query["ID"] = "druid-historical-#{node["hostname"]}"
      query["Name"] = "druid-historical"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 8083
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["druid"]["historical"]["registered"] = true
      Chef::Log.info("Druid Historical service has been registered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["druid"]["historical"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/druid-historical-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["druid"]["historical"]["registered"] = false
      Chef::Log.info("Druid Historical service has been deregistered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

# Cookbook Name:: kafka
#
# Provider:: broker
#
include Druid::Broker
include Druid::Helper

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/broker"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    memcached_hosts = new_resource.memcached_hosts
    processing_threads = new_resource.processing_threads
    groupby_max_intermediate_rows = new_resource.groupby_max_intermediate_rows
    groupby_max_results = new_resource.groupby_max_results
    cpu_num = new_resource.cpu_num
    memory_kb = new_resource.memory_kb
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port
    zookeeper_hosts = new_resource.zookeeper_hosts
    psql_uri = new_resource.psql_uri
    psql_user = new_resource.psql_user
    psql_password = new_resource.psql_password
    s3_bucket = new_resource.s3_bucket
    s3_acess_key = new_resource.s3_acess_key
    s3_secret_key = new_resource.s3_secret_key
    s3_prefix = new_resource.s3_prefix
    druid_local_storage_dir = new_resource.druid_local_storage_dir

    service "druid-broker" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    user user do
      action :create
    end

    [ parent_config_dir, config_dir, "/etc/sysconfig", "#{parent_config_dir}/_common" ].each do |path|
        directory path do
         owner "root"
         group "root"
         mode 0700
        end
    end

    [ parent_log_dir, log_dir ].each do |path|
        directory path do
          owner user
          group group
          mode 0700
        end
    end

    if s3_bucket.nil?
        directory druid_local_storage_dir do
          owner user
          group group
          mode 0700
          recursive true
        end
    end

    #################################
    # Broker resource configuration #
    #################################
    heap_broker_memory_kb = 0

    # Compute the number of processing threads based on CPUs
    processing_threads = cpu_num > 1 ? cpu_num - 1 : 1 if processing_threads.nil?

    # Compute the heap memory, the processing buffer memory and the offheap memory
    heap_broker_memory_kb, processing_memory_buffer_b = compute_memory(memory_kb, processing_threads)
    offheap_broker_memory_kb = (processing_memory_buffer_b * (processing_threads + 1) / 1024).to_i

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
      source "broker.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port, :memcached_hosts => memcached_hosts, 
                :processing_threads => processing_threads, :processing_memory_buffer_b => processing_memory_buffer_b,
                :groupby_max_intermediate_rows => groupby_max_intermediate_rows, :groupby_max_results => groupby_max_results)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source "log4j2.xml.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:log_dir => log_dir, :service_name => suffix_log_dir)
      notifies :restart, 'service[druid-broker]', :delayed
    end    

    template "#{parent_config_dir}/_common/common.runtime.properties" do
      source "common.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:zookeeper_hosts => zookeeper_hosts, :psql_uri => psql_uri, :psql_user => psql_user,
                :psql_password => psql_password, :s3_bucket => s3_bucket, :s3_acess_key => s3_acess_key,
                :s3_secret_key => s3_secret_key, :s3_prefix => s3_prefix, :druid_local_storage_dir => druid_local_storage_dir)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    template "/etc/sysconfig/druid_broker" do
      source "broker_sysconfig.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:heap_broker_memory_kb => heap_broker_memory_kb, :offheap_broker_memory_kb => offheap_broker_memory_kb, 
                :rmi_address => rmi_address, :rmi_port => rmi_port)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    # service "druid-broker" do
    #   supports :status => true, :start => true, :restart => true, :reload => true
    #   action :start
    # end

    node.set["druid"]["services"]["broker"] = true

    Chef::Log.info("Druid Broker has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/broker"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service "druid-broker" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :stop
    end

    node.set["druid"]["services"]["broker"] = false

    dir_list = [
      config_dir,
      log_dir
    ]  

    template_list = [
      "#{config_dir}/runtime.properties",
      "#{config_dir}/log4j2.xml"
    ]

    template_list.each do |temp|
       file temp do
         action :delete
       end
    end

    dir_list.each do |dir|
       directory dir do
         recursive true
         action :delete
       end
    end 

    # Remove _common directory and file only if all druid services are disabled on this node.
    if all_services_disable?
      directory "#{parent_config_dir}/_common" do
        recursive true
        action :delete
      end 
    end

    # Remove parent log directory if it doesn't have childs
    delete_if_empty(parent_log_dir)
    delete_if_empty("/etc/sysconfig")

    Chef::Log.info("Druid Broker has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


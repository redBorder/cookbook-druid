# Cookbook Name:: druid
#
# Provider:: middlemanager
#
action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/middlemanager"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    suffix_task_log_dir = new_resource.suffix_task_log_dir
    task_log_dir = "#{log_dir}/#{suffix_task_log_dir}"
    port = new_resource.port
    worker_capacity = new_resource.worker_capacity
    capacity_multiplier = new_resource.capacity_multiplier
    processing_memory_buffer_b = new_resource.processing_memory_buffer_b
    processing_threads = new_resource.processing_threads
    s3_log_bucket = new_resource.s3_log_bucket
    s3_log_prefix = new_resource.s3_log_prefix
    base_dir = new_resource.base_dir
    indexing_dir = new_resource.indexing_dir
    hadoop_version = new_resource.hadoop_version
    s3_access_key = new_resource.s3_access_key
    s3_secret_key = new_resource.s3_secret_key
    heap_memory_peon_kb = new_resource.heap_memory_peon_kb
    max_direct_memory_peon_kb = new_resource.max_direct_memory_peon_kb
    rmi_address = new_resource.rmi_address
    cpu_num = new_resource.cpu_num
    memory_kb = new_resource.memory_kb

    service "druid-middlemanager" do
       supports :status => true, :start => true, :restart => true, :reload => true
       action :nothing
     end

    user user do
      action :create
    end

    [ parent_config_dir, config_dir].each do |path|
        directory path do
         owner "root"
         group "root"
         mode 0700
        end
    end

    [ parent_log_dir, log_dir, task_log_dir, base_dir, indexing_dir, "#{indexing_dir}/tasks", "#{indexing_dir}/hadoop" ].each do |path|
        directory path do
          owner user
          group group
          mode 0700
        end
    end

    ########################################
    # Middlemanager resource configuration #
    ########################################

      # 256mb to middlemanager heap
      memory_kb = memory_kb - (256*1024) 

      # 1gb per peon heap or 60% of total RAM
      heap_memory_peon_kb = memory_kb > (2*1024*1024).to_i ? (1*1024*1024).to_i : (memory_kb * 0.60).to_i if heap_memory_peon_kb.nil?

      # Number of min[(cpu - 1),2] or 1
      processing_threads = cpu_num > 1 ? [cpu_num - 1, 2].min : 1 if processing_threads.nil?
    
      # 256mb per threads or [40% of total RAM / (threads + 1)]
      processing_memory_buffer_b = (memory_kb - heap_memory_peon_kb) > (512*1024) * (processing_threads + 1) ? (512*1024*1024) :  ((memory_kb - heap_memory_peon_kb) / (processing_threads + 1)).to_i if processing_memory_buffer_b.nil?
    
      # (Threads + 1) * processing_memory to calculate peon MaxDirectMemory (off-heap)
      max_direct_memory_peon_kb = (processing_memory_buffer_b * (processing_threads + 1) / 1024).to_i if max_direct_memory_peon_kb.nil?

      # Total memory per tasks
      total_memory_per_task_kb = heap_memory_peon_kb + max_direct_memory_peon_kb

      # Worker capacity based on min(MemoryPerTasks, CPUs)
      worker_capacity = [[(memory_kb / total_memory_per_task_kb), cpu_num * 2].min, 1].max.to_i if worker_capacity.nil?

      # Recalculate heap memory if the limit is the CPUs
      total_memory_per_task_kb = (memory_kb / worker_capacity).to_i
      heap_memory_peon_kb = total_memory_per_task_kb - max_direct_memory_peon_kb
      Chef::Log.info("PeonHeapMemory: #{heap_memory_peon_kb}kb PeonOffHeapMemory: #{max_direct_memory_peon_kb}kb TotalCapcity: #{worker_capacity}")
    ########################################
    ########################################

    template "#{config_dir}/runtime.properties" do
      source "middlemanager.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port, :task_log_dir => task_log_dir, 
                :worker_capacity => worker_capacity, :capacity_multiplier => capacity_multiplier,
                :processing_memory_buffer_b => processing_memory_buffer_b, :processing_threads => processing_threads,
                :s3_log_bucket => s3_log_bucket, :s3_log_prefix => s3_log_prefix, :base_dir => base_dir,
                :indexing_dir => indexing_dir, :hadoop_version => hadoop_version, :s3_access_key => s3_access_key,
                :s3_secret_key => s3_secret_key, :heap_memory_peon_kb => heap_memory_peon_kb, :max_direct_memory_peon_kb => max_direct_memory_peon_kb,
                :rmi_address => rmi_address)
      notifies :restart, 'service[druid-middlemanager]', :delayed
    end

    # service "druid-middlemanager" do
    #   supports :status => true, :start => true, :restart => true, :reload => true
    #   action :start
    # end

    Chef::Log.info("Druid Middlemanager has been configurated correctly.")
  rescue => e
    Chef::Log.error(e)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/middlemanager"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    suffix_task_log_dir = new_resource.suffix_task_log_dir
    task_log_dir = "#{log_dir}/#{suffix_task_log_dir}"
    base_dir = new_resource.base_dir
    indexing_dir = new_resource.indexing_dir

    service "druid-broker" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :stop
    end

    dir_list = [
      config_dir,
      task_log_dir,
      log_dir,
      indexing_dir
    ]  

    template_list = [
      "#{config_dir}/runtime.properties"
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

    # Remove parent log directory if it doesn't have childs
    delete_if_empty(parent_log_dir)
    delete_if_empty(base_dir)

    Chef::Log.info("Druid Middlemanager has been deleted correctly.")
  rescue => e
    Chef::Log.error(e)
  end
end


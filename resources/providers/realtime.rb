# Cookbook Name:: druid
#
# Provider:: Realtime
#

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/realtime"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    port = new_resource.port
    processing_memory_buffer_b = new_resource.processing_memory_buffer_b
    processing_threads = new_resource.processing_threads
    base_dir = new_resource.base_dir
    cpu_num = new_resource.cpu_num
    memory_kb = new_resource.memory_kb
    heap_realtime_memory_kb = new_resource.heap_realtime_memory_kb
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port
    num_threads = new_resource.num_threads
    zk_hosts = new_resource.zookeeper_hosts
    partition_num = new_resource.partition_num
    max_rows_in_memory = new_resource.max_rows_in_memory

    directory config_dir do
      owner "root"
      group "root"
      mode 0755
    end

    [ base_dir, log_dir ].each do |path|
        directory path do
          owner user
          group group
          mode 0755
        end
    end

    ########################################
    # Realtime resource configuration #
    ########################################

      # reserve realtime heap
      #memory_kb = memory_kb - heap_realtime_memory_kb

      # Number of min[(cpu - 1),1] or 1
      processing_threads = cpu_num > 1 ? [cpu_num - 1, 2].min : 1 if processing_threads.nil?
      #processing_threads = cpu_num > 1 ? [cpu_num - 1, 1].max : 1 if processing_threads.nil?

      # 256mb per threads or [40% of total RAM / (threads + 1)]
      # processing_memory_buffer_b = (memory_kb - heap_memory_peon_kb) > (512*1024) * (processing_threads + 1) ? (512*1024*1024) :  ((memory_kb - heap_memory_peon_kb) / (processing_threads + 1)).to_i if processing_memory_buffer_b.nil?
      heap_realtime_memory_kb = ((512*1024)*processing_threads+1).to_i
      #processing_memory_buffer_b = [ 2147483647, (memory_kb.to_i*1024/processing_threads).to_i].min.to_s
      processing_memory_buffer_b = ((((memory_kb.to_i-(memory_kb.to_i*0.05))*1024)-heap_realtime_memory_kb)/(processing_threads+1)).to_i.to_s

      Chef::Log.info(
      "\nRealtime Memory:
        * Memory: #{memory_kb}k
        * Heap Realtime: #{heap_realtime_memory_kb}kb
        * #Threads: #{processing_threads}
        * #cpu_num: #{cpu_num}
        * #processing_memory_buffer_b: #{processing_memory_buffer_b}
      "
      )
    ########################################
    ########################################

    template "#{config_dir}/runtime.properties" do
      source "realtime.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port,
                :processing_memory_buffer_b => processing_memory_buffer_b, :processing_threads => processing_threads,
                :base_dir => base_dir, :rmi_address => rmi_address)
      notifies :restart, 'service[druid-realtime]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source "log4j2.xml.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:log_dir => log_dir, :service_name => suffix_log_dir)
      notifies :restart, 'service[druid-realtime]', :delayed
    end

    template "/etc/sysconfig/druid_realtime" do
      source "realtime_sysconfig.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:heap_realtime_memory_kb => heap_realtime_memory_kb, :rmi_address => rmi_address, :rmi_port => rmi_port, :parent_config_dir => parent_config_dir, :memory_kb => memory_kb)
      notifies :restart, 'service[druid-realtime]', :delayed
    end

    template "/etc/druid/realtime/rb_realtime.spec" do
      source "realtime.spec.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:zookeeper => zk_hosts, :max_rows => max_rows_in_memory, :partition_num => partition_num)
      helpers Druid::Realtime
    end

    service "druid-realtime" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action [:enable,:start]
    end

    Chef::Log.info("Druid cookbook (realtime) has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/realtime"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    base_dir = new_resource.base_dir

    service "druid-realtime" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action [:disable,:stop]
    end

    template_list = [
      "#{config_dir}/runtime.properties",
      "#{config_dir}/log4j2.xml"
    ]

    #template_list.each do |temp|
    #   file temp do
    #     action :delete
    #   end
    #end

    dir_list = [
      config_dir,
      log_dir
    ]

    #dir_list.each do |dir|
    #   directory dir do
    #     recursive true
    #     action :delete
    #   end
    #end

    Chef::Log.info("Druid realtime cookbook has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :register do
  begin
    if !node["druid"]["realtime"]["registered"]
      query = {}
      query["ID"] = "druid-realtime-#{node["hostname"]}"
      query["Name"] = "druid-realtime"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 8084
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["druid"]["realtime"]["registered"] = true
      Chef::Log.info("Druid realtime service has been deregistered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["druid"]["realtime"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/druid-realtime-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["druid"]["realtime"]["registered"] = false
      Chef::Log.info("Druid realtime service has been deregistered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

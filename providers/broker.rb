# Cookbook Name:: kafka
#
# Provider:: broker
#

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/broker"
    parent_log_dir = new_resource.parent_log_dir
    log_dir = new_resource.log_dir
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    memcached_hosts = new_resource.memcached_hosts
    processing_threads = new_resource.processing_threads
    processing_memory_buffer = new_resource.processing_memory_buffer
    groupby_max_intermediate_rows = new_resource.groupby_max_intermediate_rows
    groupby_max_results = new_resource.groupby_max_results

    service "druid-broker" do
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

    [ parent_log_dir, "#{parent_log_dir}/#{log_dir}" ].each do |path|
        directory path do
          owner user
          group group
          mode 0700
        end
    end

    template "#{config_dir}/runtime.properties" do
      source "broker.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port, :memcached_hosts => memcached_hosts, 
                :processing_threads => processing_threads, :processing_memory_buffer => processing_memory_buffer,
                :groupby_max_intermediate_rows => groupby_max_intermediate_rows, :groupby_max_results => groupby_max_results)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    service "druid-broker" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :start, :delayed
    end

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
    log_dir = new_resource.log_dir

    service "druid-broker" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :stop
    end

    dir_list = [
      config_dir,
      "#{parent_log_dir}/#{log_dir}"
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
         action :delete
       end
    end

     Chef::Log.info("Druid Broker has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


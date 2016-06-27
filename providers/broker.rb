# Cookbook Name:: kafka
#
# Provider:: broker
#

action :add do
  begin
    config_dir_parent = "/etc/druid"
    config_dir = "#{config_dir_parent}/broker"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
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

    [ config_dir_parent, config_dir].each do |path|
        directory path do
         owner "root"
         group "root"
         mode 0700
        end
    end

    template "#{config_dir}/broker.properties" do
      source "broker.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :memcached_hosts => memcached_hosts, 
                :processing_threads => processing_threads, :processing_memory_buffer => processing_memory_buffer,
                :groupby_max_intermediate_rows => groupby_max_intermediate_rows, :groupby_max_results => groupby_max_results)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    Chef::Log.info("Druid Broker has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
     # ... your code here ... 
     Chef::Log.info("Druid Broker has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


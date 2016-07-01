# Cookbook Name:: kafka
#
# Provider:: coordinator
#
include Druid::Helper

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/coordinator"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port
    memory_kb = new_resource.memory_kb
    zookeeper_hosts = new_resource.zookeeper_hosts
    psql_uri = new_resource.psql_uri
    psql_user = new_resource.psql_user
    psql_password = new_resource.psql_password
    s3_bucket = new_resource.s3_bucket
    s3_acess_key = new_resource.s3_acess_key
    s3_secret_key = new_resource.s3_secret_key
    s3_prefix = new_resource.s3_prefix
    druid_local_storage_dir = new_resource.druid_local_storage_dir

    service "druid-coordinator" do
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

    template "#{config_dir}/runtime.properties" do
      source "coordinator.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port)
      notifies :restart, 'service[druid-coordinator]', :delayed
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
      notifies :restart, 'service[druid-coordinator]', :delayed
    end

    template "/etc/sysconfig/druid_coordinator" do
      source "coordinator_sysconfig.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:heap_coordinator_memory_kb => (memory_kb * 0.8).to_i, :offheap_coordinator_memory_kb => (memory_kb * 0.2).to_i, 
                :rmi_address => rmi_address, :rmi_port => rmi_port)
      notifies :restart, 'service[druid-broker]', :delayed
    end

    # service "druid-coordinator" do
    #   supports :status => true, :start => true, :restart => true, :reload => true
    #   action :start, :delayed
    # end

    Chef::Log.info("Druid Coordinator has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/coordinator"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service "druid-coordinator" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :stop
    end

    dir_list = [
      config_dir,
      log_dir
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
    delete_if_empty("/etc/sysconfig")

    Chef::Log.info("Druid Coordinator has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


# Cookbook Name:: kafka
#
# Provider:: overlord
#
include Druid::Helper

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/overlord"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    task_log_dir = "#{log_dir}/indexing"
    user = new_resource.user
    group = new_resource.group
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    s3_bucket = new_resource.s3_bucket
    s3_prefix = new_resource.s3_prefix
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

    service "druid-overlord" do
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
         mode 0755
        end
    end

    [ parent_log_dir, log_dir, task_log_dir ].each do |path|
        directory path do
          owner user
          group group
          mode 0755
        end
    end

    if s3_bucket.nil?
        directory druid_local_storage_dir do
          owner user
          group group
          mode 0755
          recursive true
        end
    end
    
    template "#{config_dir}/runtime.properties" do
      source "overlord.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:name => name, :cdomain => cdomain, :port => port,
                :s3_bucket => s3_bucket, :s3_prefix => s3_prefix,
                :task_log_dir => task_log_dir)
      notifies :restart, 'service[druid-overlord]', :delayed
    end

    template "#{config_dir}/log4j2.xml" do
      source "log4j2.xml.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:log_dir => log_dir, :service_name => suffix_log_dir)
      notifies :restart, 'service[druid-overlord]', :delayed
    end    

    extensions = ["druid-kafka-indexing-service", "druid-kafka-eight", "druid-histogram"]
    extensions << "druid-s3-extensions" if !s3_bucket.nil?
    extensions << "postgresql-metadata-storage" if !psql_uri.nil?

    template "#{parent_config_dir}/_common/common.runtime.properties" do
      source "common.properties.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:zookeeper_hosts => zookeeper_hosts, :psql_uri => psql_uri, :psql_user => psql_user,
                :psql_password => psql_password, :s3_bucket => s3_bucket, :s3_acess_key => s3_acess_key,
                :s3_secret_key => s3_secret_key, :s3_prefix => s3_prefix, :druid_local_storage_dir => druid_local_storage_dir,
                :extensions => extensions)
      notifies :restart, 'service[druid-overlord]', :delayed
    end

    template "/etc/sysconfig/druid_overlord" do
      source "overlord_sysconfig.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:heap_overlord_memory_kb => memory_kb, :rmi_address => rmi_address, :rmi_port => rmi_port)
      notifies :restart, 'service[druid-overlord]', :delayed
    end

    # service "druid-overlord" do
    #   supports :status => true, :start => true, :restart => true, :reload => true
    #   action :start, :delayed
    # end

    node.set["druid"]["services"]["overlord"] = true

    Chef::Log.info("Druid Overlord has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/overlord"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service "druid-coordinator" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :stop
    end

    node.set["druid"]["services"]["overlord"] = false

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

    Chef::Log.info("Druid Overlord has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

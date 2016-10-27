# Cookbook Name:: kafka
#
# Provider:: broker
#

include Druid::Helper

action :add do
  begin
    parent_config_dir = "/etc/druid"
    parent_log_dir = new_resource.parent_log_dir
    user = new_resource.user
    group = new_resource.group
    zookeeper_hosts = new_resource.zookeeper_hosts
    psql_uri = new_resource.psql_uri
    psql_user = new_resource.psql_user
    psql_password = new_resource.psql_password
    memcached_hosts = new_resource.memcached_hosts
    s3_bucket = new_resource.s3_bucket
    s3_access_key = new_resource.s3_access_key
    s3_secret_key = new_resource.s3_secret_key
    s3_prefix = new_resource.s3_prefix
    druid_local_storage_dir = new_resource.druid_local_storage_dir

    ################
    # DRUID SERVICES
    ################ 

    service "druid-broker" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    service "druid-coordinator" do
       supports :status => true, :start => true, :restart => true, :reload => true
       action :nothing
    end

    service "druid-historical" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    service "druid-middlemanager" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    service "druid-overlord" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    ####################
    # READ DATABAGS
    ####################

    #Obtaining s3 data
    s3 = Chef::DataBagItem.load("passwords", "s3") rescue s3 = {}
    if !s3.empty?
      s3_bucket = s3["s3_bucket"]
      s3_access_key = s3["s3_access_key_id"]
      s3_secret_key = s3["s3_secret_key_id"]
    end

     #Obtaining druid database configuration from databag
    db_druid = Chef::DataBagItem.load("passwords", "db_druid") rescue db_druid = {}
    if !db_druid.empty?
      psql_uri = "#{db_druid["hostname"]}:#{db_druid["port"]}"
      psql_user = db_druid["username"]
      psql_password = db_druid["pass"]
    end

    #######################
    # Druid installation
    #######################
    yum_package "redborder-druid" do
      action :upgrade
      flush_cache [:before]
    end

    ####################################
    # Users and directories creation
    ####################################

    user user do
      action :create
    end

    [ parent_config_dir, "/etc/sysconfig", "#{parent_config_dir}/_common" ].each do |path|
        directory path do
         owner "root"
         group "root"
         mode 0755
        end
    end

    directory parent_log_dir do
      owner user
      group group
      mode 0755
    end

    if s3_bucket.nil?
        directory druid_local_storage_dir do
          owner user
          group group
          mode 0755
          recursive true
        end
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
      variables(:zookeeper_hosts => zookeeper_hosts, :psql_uri => psql_uri, :psql_user => psql_user, :memcached_hosts => memcached_hosts
                :psql_password => psql_password, :s3_bucket => s3_bucket, :s3_access_key => s3_access_key,
                :s3_secret_key => s3_secret_key, :s3_prefix => s3_prefix, :druid_local_storage_dir => druid_local_storage_dir,
                :extensions => extensions)
      notifies node["redborder"]["services"]["druid-broker"] ? :restart : :nothing, 'service[druid-broker]', :delayed
      notifies node["redborder"]["services"]["druid-coordinator"] ? :restart : :nothing, 'service[druid-coordinator]', :delayed
      notifies node["redborder"]["services"]["druid-historical"] ? :restart : :nothing, 'service[druid-historical]', :delayed
      notifies node["redborder"]["services"]["druid-middlemanager"] ? :restart : :nothing, 'service[druid-middlemanager]', :delayed
      notifies node["redborder"]["services"]["druid-overlord"] ? :restart : :nothing, 'service[druid-overlord]', :delayed
    end

    Chef::Log.info("Druid cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    parent_log_dir = new_resource.parent_log_dir
    node.set["druid"]["services"]["broker"] = false

    directory "#{parent_config_dir}/_common" do
      recursive true
      action :delete
    end

    # Remove parent log directory if it doesn't have childs
    delete_if_empty(parent_log_dir)
    delete_if_empty("/etc/sysconfig")

    Chef::Log.info("Druid cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

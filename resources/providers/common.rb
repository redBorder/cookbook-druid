# Cookbook:: druid
# Provider:: broker

include Druid::Helper

action :add do
  begin
    parent_config_dir = '/etc/druid'
    parent_log_dir = new_resource.parent_log_dir
    user = new_resource.user
    group = new_resource.group
    zookeeper_hosts = new_resource.zookeeper_hosts
    psql_uri = new_resource.psql_uri
    psql_user = new_resource.psql_user
    psql_password = new_resource.psql_password
    memcached_hosts = new_resource.memcached_hosts
    s3_prefix = new_resource.s3_prefix
    s3_service = new_resource.s3_service
    s3_port = new_resource.s3_port
    druid_local_storage_dir = new_resource.druid_local_storage_dir
    s3_region = new_resource.s3_region
    s3_secrets = new_resource.s3_secrets

    # DRUID SERVICES
    service 'druid-broker' do
      supports status: true, start: true, restart: true, reload: true
      action :nothing
    end

    service 'druid-coordinator' do
      supports status: true, start: true, restart: true, reload: true
      action :nothing
    end

    service 'druid-historical' do
      supports status: true, start: true, restart: true, reload: true
      action :nothing
    end

    service 'druid-middlemanager' do
      supports status: true, start: true, restart: true, reload: true
      action :nothing
    end

    service 'druid-overlord' do
      supports status: true, start: true, restart: true, reload: true
      action :nothing
    end

    ####################
    # READ DATABAGS
    ####################

    # Obtaining s3 data
    unless s3_secrets.empty?
      s3_bucket = s3_secrets['s3_bucket']
      s3_access_key = s3_secrets['s3_access_key_id']
      s3_secret_key = s3_secrets['s3_secret_key_id']
    end

    # Obtaining druid database configuration from databag
    begin
      db_druid = data_bag_item('passwords', 'db_druid')
    rescue
      db_druid = {}
    end

    unless db_druid.empty?
      psql_uri = "#{db_druid['hostname']}:#{db_druid['port']}"
      psql_user = db_druid['username']
      psql_password = db_druid['pass']
    end

    #######################
    # Druid installation
    #######################
    dnf_package 'redborder-druid' do
      action :upgrade
    end

    ####################################
    # Users and directories creation
    ####################################
    execute 'create_user' do
      command "/usr/sbin/useradd #{user}"
      ignore_failure true
      not_if "getent passwd #{user}"
    end

    [parent_config_dir, '/etc/sysconfig', "#{parent_config_dir}/_common"].each do |path|
      directory path do
        owner 'root'
        group 'root'
        mode '0755'
      end
    end

    directory parent_log_dir do
      owner user
      group group
      mode '0755'
    end

    unless s3_bucket
      directory druid_local_storage_dir do
        owner user
        group group
        mode '0755'
        recursive true
      end
    end

    extensions = %w(druid-kafka-indexing-service kafka-emitter)
    extensions << 'druid-s3-extensions' if s3_bucket
    extensions << 'postgresql-metadata-storage' if psql_uri

    template "#{parent_config_dir}/_common/common.runtime.properties" do
      source 'common.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(zookeeper_hosts: zookeeper_hosts,
                psql_uri: psql_uri, psql_user: psql_user, memcached_hosts: memcached_hosts,
                psql_password: psql_password, s3_bucket: s3_bucket, s3_access_key: s3_access_key, s3_service: s3_service, s3_port: s3_port,
                s3_secret_key: s3_secret_key, s3_prefix: s3_prefix, druid_local_storage_dir: druid_local_storage_dir, s3_region: s3_region,
                extensions: extensions)
    end

    template "#{parent_config_dir}/_common/jets3t.properties" do
      source 'jets3t.properties.erb'
      owner 'root'
      group 'root'
      cookbook 'druid'
      mode '0644'
      retries 2
      variables(s3_bucket: s3_bucket, s3_service: s3_service, s3_port: s3_port)
    end

    Chef::Log.info('Druid cookbook (common) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    # parent_config_dir = '/etc/druid'
    # parent_log_dir = new_resource.parent_log_dir
    node.normal['druid']['services']['broker'] = false

    # removing package
    # bash 'dummy-delay-druid-uninstall' do
    #   notifies :remove, 'dnf_package[redborder-druid]' , :delayed
    # end
    # dnf_package 'redborder-druid' do
    #   action :nothing
    # end

    # directory "#{parent_config_dir}/_common" do
    #   recursive true
    #   action :delete
    # end

    # Remove parent log directory if it doesn't have childs
    # delete_if_empty(parent_log_dir)

    Chef::Log.info('Druid cookbook (common) has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

# Cookbook Name:: kafka
#
# Provider:: overlord
#

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

    service "druid-overlord" do
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

    [ parent_log_dir, log_dir, task_log_dir ].each do |path|
        directory path do
          owner user
          group group
          mode 0700
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

    # service "druid-overlord" do
    #   supports :status => true, :start => true, :restart => true, :reload => true
    #   action :start, :delayed
    # end

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
    if Dir["#{parent_log_dir}/*"].empty? 
       directory parent_log_dir do
         action :delete
       end
    end

     Chef::Log.info("Druid Overlord has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


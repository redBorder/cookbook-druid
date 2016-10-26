# Cookbook Name:: kafka
#
# Provider:: coordinator
#

action :add do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/coordinator"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"
    name = new_resource.name
    cdomain = new_resource.cdomain
    port = new_resource.port
    rmi_address = new_resource.rmi_address
    rmi_port = new_resource.rmi_port
    memory_kb = new_resource.memory_kb

    service "druid-coordinator" do
       supports :status => true, :start => true, :restart => true, :reload => true
       action :nothing
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

    template "#{config_dir}/log4j2.xml" do
      source "log4j2.xml.erb"
      owner "root"
      group "root"
      cookbook "druid"
      mode 0644
      retries 2
      variables(:log_dir => log_dir, :service_name => suffix_log_dir)
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
      notifies :restart, 'service[druid-coordinator]', :delayed
    end     

    node.set["druid"]["services"]["coordinator"] = true

    Chef::Log.info("Druid cookbook (coordinator) has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/druid"
    config_dir = "#{parent_config_dir}/coordinator"    

    service "druid-coordinator" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :stop
    end

    node.set["druid"]["services"]["coordinator"] = false

    template_list = [
      "#{config_dir}/runtime.properties",
      "#{config_dir}/log4j2.xml"
    ]

    template_list.each do |temp|
       file temp do
         action :delete
       end
    end    

    Chef::Log.info("Druid cookbook (coordinator) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    if !node["druid-coordinator"]["registered"]
      query = {}
      query["ID"] = "druid-coordinator-#{node["hostname"]}"
      query["Name"] = "druid-coordinator"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 8081
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["druid-coordinator"]["registered"] = true
    end

    Chef::Log.info("Druid Coordinator service has been registered to consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["druid-coordinator"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/druid-coordinator-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["druid-coordinator"]["registered"] = false
    end

    Chef::Log.info("Druid Coordinator service has been deregistered to consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

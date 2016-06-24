# Cookbook Name:: kafka
#
# Provider:: coordinator
#

action :add do
  begin
    # ... your code here ...
    Chef::Log.info("Druid Coordinator has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
     # ... your code here ... 
     Chef::Log.info("Druid Coordinator has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


# Cookbook Name:: kafka
#
# Provider:: overlord
#

action :add do
  begin
    # ... your code here ...
    Chef::Log.info("Druid Overlord has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
     # ... your code here ... 
     Chef::Log.info("Druid Overlord has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


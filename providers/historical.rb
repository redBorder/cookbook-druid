# Cookbook Name:: kafka
#
# Provider:: historical
#

action :add do
  begin
    # ... your code here ...
    Chef::Log.info("Druid Historical has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
     # ... your code here ... 
     Chef::Log.info("Druid Historical has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


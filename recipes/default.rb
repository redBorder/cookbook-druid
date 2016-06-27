#
# Cookbook Name:: druid
# Recipe:: default
#
# Copyright 2016, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#


druid_historical "Configure Druid Historical" do
  memory "512"
end

druid_broker "Configure Druid Broker" do
  name "localhost"
  action :add
end

druid_coordinator "Configure Druid coordinator" do
  name "localhost"
    action :add
end

druid_overlord "Configure Druid overlord" do
  memory "512"
end

druid_overlord "Configure Druid middlemanager" do
  memory "512"
end

druid_overlord "Configure Druid realtime" do
  memory "512"
end



#
# Cookbook Name:: druid
# Recipe:: default
#
# Copyright 2016, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#


druid_historical "Configure Druid Historical" do
  name "localhost"
  action :add
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
  name "localhost"
  action :add
end

druid_middlemanager "Configure Druid middlemanager" do
  name "localhost"
  action :add
end



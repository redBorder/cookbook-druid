# Cookbook:: druid
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

memory_mb = (node['memory']['total'].match(/\A(?<value>\d+)(?<modifier>\w+)\z/)[:value].to_i / 1024 * 0.90).to_i

druid_historical 'Configure Druid Historical' do
  druid_historical_name 'localhost'
  memory_kb (memory_mb * 0.2).to_i
  action :add
end

druid_broker 'Configure Druid Broker' do
  druid_broker_name 'localhost'
  memory_kb (memory_mb * 0.2).to_i
  action :add
end

druid_coordinator 'Configure Druid coordinator' do
  druid_coordinator_name 'localhost'
  memory_kb (memory_mb * 0.1).to_i
  action :add
end

druid_overlord 'Configure Druid overlord' do
  druid_overlord_name 'localhost'
  memory_kb (memory_mb * 0.1).to_i
  action :add
end

druid_middlemanager 'Configure Druid middlemanager' do
  druid_middlemanager_name 'localhost'
  memory_kb (memory_mb * 0.4).to_i
  action :add
end

druid_realtime 'Configure Druid realtime' do
  druid_realtime_name 'localhost'
  memory_kb (memory_mb * 0.4).to_i
  action :add
end

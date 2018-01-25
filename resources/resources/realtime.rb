# Cookbook Name:: druid
#
# Resource:: Realtime
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, :kind_of => String, :default => "druid"
attribute :group, :kind_of => String, :default => "druid"
attribute :name, :kind_of => String, :default => "localhost"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/druid"
attribute :suffix_log_dir, :kind_of => String, :default => "realtime"
attribute :port, :kind_of => Integer, :default => 8084
attribute :s3_access_key, :kind_of => String
attribute :s3_secret_key, :kind_of => String
attribute :s3_log_bucket, :kind_of => String
attribute :s3_log_prefix, :kind_of => String, :default => "druid-indexer-logs"
attribute :base_dir, :kind_of => String, :default => "/tmp/druid"
attribute :cpu_num, :kind_of => Integer, :default => node["cpu"]["total"]
attribute :memory_kb, :kind_of => Integer, :default => 3145728
attribute :processing_memory_buffer_b, :kind_of => Integer
attribute :processing_threads, :kind_of => Integer
attribute :heap_realtime_memory_kb, :kind_of => Integer, :default => 262144
attribute :rmi_address, :kind_of => String, :default => "127.0.0.1"
attribute :rmi_port, :kind_of => String, :default => "9084"
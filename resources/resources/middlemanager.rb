# Cookbook Name:: druid
#
# Resource:: middlemanager
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, :kind_of => String, :default => "druid"
attribute :group, :kind_of => String, :default => "druid"
attribute :name, :kind_of => String, :default => "localhost"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/druid"
attribute :suffix_log_dir, :kind_of => String, :default => "middlemanager"
attribute :suffix_task_log_dir, :kind_of => String, :default => "tasks"
attribute :port, :kind_of => Integer, :default => 8091
attribute :s3_access_key, :kind_of => String
attribute :s3_secret_key, :kind_of => String
attribute :s3_log_bucket, :kind_of => String
attribute :s3_log_prefix, :kind_of => String, :default => "druid-indexer-logs"
attribute :base_dir, :kind_of => String, :default => "/tmp/druid"
attribute :indexing_dir, :kind_of => String, :default => "/tmp/druid/indexing"
attribute :hadoop_version, :kind_of => String, :default => "2.7.1"
attribute :rmi_address, :kind_of => String, :default => "127.0.0.1"
attribute :capacity_multiplier, :kind_of => Integer, :default => 1
attribute :cpu_num, :kind_of => Integer, :default => 1
attribute :memory_kb, :kind_of => Integer, :default => 3145728
attribute :worker_capacity, :kind_of => Integer
attribute :processing_memory_buffer_b, :kind_of => Integer
attribute :processing_threads, :kind_of => Integer
attribute :heap_memory_peon_kb, :kind_of => Integer
attribute :max_direct_memory_peon_kb, :kind_of => Integer
attribute :heap_middlemanager_memory_kb, :kind_of => Integer, :default => 262144
attribute :rmi_address, :kind_of => String, :default => "127.0.0.1"
attribute :rmi_port, :kind_of => String, :default => "9085"
attribute :zookeeper_hosts, :kind_of => String, :default => "localhost:2181"
attribute :psql_uri, :kind_of => String
attribute :psql_user, :kind_of => String
attribute :psql_password, :kind_of => String
attribute :s3_bucket, :kind_of => String
attribute :s3_access_key, :kind_of => String
attribute :s3_secret_key, :kind_of => String
attribute :s3_prefix, :kind_of => String, :default => "rbdata"
attribute :druid_local_storage_dir, :kind_of => String, :default => "/tmp/druid/localStorage"

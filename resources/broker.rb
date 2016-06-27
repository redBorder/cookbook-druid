# Cookbook Name:: druid
#
# Resource:: broker
#

actions :add, :remove
default_action :add

attribute :user, :kind_of => String, :default => "druid"
attribute :group, :kind_of => String, :default => "druid"
attribute :name, :kind_of => String, :default => "localhost"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :port, :kind_of => Integer, :default => 8080
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/druid"
attribute :log_dir, :kind_of => String, :default => "broker"
attribute :memcached_hosts, :kind_of => String
attribute :processing_threads, :kind_of => Integer, :default => 1
attribute :processing_memory_buffer, :kind_of => Integer, :default => 268435456
attribute :groupby_max_intermediate_rows, :kind_of => Integer, :default => 50000
attribute :groupby_max_results, :kind_of => Integer, :default => 500000
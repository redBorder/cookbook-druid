# Cookbook Name:: druid
#
# Resource:: overlord
#

actions :add, :remove
default_action :add

attribute :user, :kind_of => String, :default => "druid"
attribute :group, :kind_of => String, :default => "druid"
attribute :name, :kind_of => String, :default => "localhost"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/druid"
attribute :suffix_log_dir, :kind_of => String, :default => "overlord"
attribute :port, :kind_of => Integer, :default => 8084
attribute :s3_bucket, :kind_of => String
attribute :s3_prefix, :kind_of => String, :default => "druid-indexer-logs"

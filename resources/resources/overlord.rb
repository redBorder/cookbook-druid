# Cookbook:: druid
# Resource:: overlord

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'druid'
attribute :group, kind_of: String, default: 'druid'
attribute :name, kind_of: String, default: 'localhost'
attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :parent_log_dir, kind_of: String, default: '/var/log/druid'
attribute :suffix_log_dir, kind_of: String, default: 'overlord'
attribute :port, kind_of: Integer, default: 8084
attribute :s3_bucket, kind_of: String
attribute :s3_prefix, kind_of: String, default: 'druid-indexer-logs'
attribute :rmi_address, kind_of: String, default: '127.0.0.1'
attribute :rmi_port, kind_of: String, default: '9084'
attribute :memory_kb, kind_of: Integer, default: 1048576
attribute :ipaddress, kind_of: String, default: '127.0.0.1'

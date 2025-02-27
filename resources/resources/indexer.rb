# Cookbook:: druid
# Resource:: indexer

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'druid'
attribute :group, kind_of: String, default: 'druid'
attribute :name, kind_of: String, default: 'localhost'
attribute :aws_region, kind_of: String, default: 'us-east-1'
attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :port, kind_of: Integer, default: 8089
attribute :parent_log_dir, kind_of: String, default: '/var/log/druid'
attribute :suffix_log_dir, kind_of: String, default: 'indexer'
attribute :rmi_address, kind_of: String, default: '127.0.0.1'
attribute :rmi_port, kind_of: String, default: '9091'
attribute :ipaddress, kind_of: String, default: '127.0.0.1'

# Cookbook:: druid
# Resource:: broker

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'druid'
attribute :group, kind_of: String, default: 'druid'
attribute :name, kind_of: String, default: 'localhost'
attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :port, kind_of: Integer, default: 8080
attribute :parent_log_dir, kind_of: String, default: '/var/log/druid'
attribute :suffix_log_dir, kind_of: String, default: 'broker'
attribute :memcached_hosts, kind_of: String
attribute :processing_threads, kind_of: Integer
attribute :groupby_max_intermediate_rows, kind_of: Integer, default: 50000
attribute :groupby_max_results, kind_of: Integer, default: 500000
attribute :cpu_num, kind_of: Integer, default: 4
attribute :memory_kb, kind_of: Integer, default: 8388608
attribute :rmi_address, kind_of: String, default: '127.0.0.1'
attribute :rmi_port, kind_of: String, default: '9080'
attribute :ipaddress, kind_of: String, default: '127.0.0.1'

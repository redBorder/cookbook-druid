# Cookbook:: druid
# Resource:: historical

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'druid'
attribute :group, kind_of: String, default: 'druid'
attribute :name, kind_of: String, default: 'localhost'
attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :port, kind_of: Integer, default: 8083
attribute :parent_log_dir, kind_of: String, default: '/var/log/druid'
attribute :suffix_log_dir, kind_of: String, default: 'historical'
attribute :segment_cache_dir, kind_of: String, default: '/var/druid/historical/indexCache'
attribute :processing_threads, kind_of: Integer
attribute :groupby_max_intermediate_rows, kind_of: Integer, default: 50000
attribute :groupby_max_results, kind_of: Integer, default: 500000
attribute :tier_memory_mode, kind_of: [TrueClass, FalseClass], default: false
attribute :cpu_num, kind_of: Integer, default: 4
attribute :memory_kb, kind_of: Integer, default: 8388608
attribute :disk_size_kb, kind_of: Integer, default: 10485760
attribute :rmi_address, kind_of: String, default: '127.0.0.1'
attribute :rmi_port, kind_of: String, default: '9091'
attribute :ipaddress, kind_of: String, default: '127.0.0.1'
attribute :maxsize, kind_of: Integer, default: 10737418240

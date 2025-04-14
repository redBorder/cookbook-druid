# Cookbook:: druid
# Resource:: common

actions :add, :remove
default_action :add

attribute :user, kind_of: String, default: 'druid'
attribute :group, kind_of: String, default: 'druid'
attribute :parent_log_dir, kind_of: String, default: '/var/log/druid'
attribute :zookeeper_hosts, kind_of: String, default: 'localhost:2181'
attribute :memcached_hosts, kind_of: Array, default: ['memcached.service:11211']
attribute :psql_uri, kind_of: String
attribute :psql_user, kind_of: String
attribute :psql_password, kind_of: String
attribute :s3_bucket, kind_of: String
attribute :s3_access_key, kind_of: String
attribute :s3_secret_key, kind_of: String
attribute :s3_region, kind_of: String, default: 'us-east-1'
attribute :s3_prefix, kind_of: String, default: 'rbdata'
attribute :s3_service, kind_of: String, default: 's3.service'
attribute :s3_port, kind_of: Integer, default: 9000
attribute :druid_local_storage_dir, kind_of: String, default: '/tmp/druid/localStorage'

# Cookbook Name:: druid
#
# Resource:: coordinator
#

actions :add, :remove
default_action :add

attribute :user, :kind_of => String, :default => "druid"
attribute :group, :kind_of => String, :default => "druid"
attribute :name, :kind_of => String, :default => "localhost"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/druid"
attribute :log_dir, :kind_of => String, :default => "coordinator"
attribute :port, :kind_of => Integer, :default => 8081


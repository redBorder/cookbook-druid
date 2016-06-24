# Cookbook Name:: druid
#
# Resource:: realtime
#

actions :add, :remove
default_action :add

attribute :memory, :kind_of => String, :default => "512"


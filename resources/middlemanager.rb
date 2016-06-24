# Cookbook Name:: druid
#
# Resource:: middlemanager
#

actions :add, :remove
default_action :add

attribute :memory, :kind_of => String, :default => "512"


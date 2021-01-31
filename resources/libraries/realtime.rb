module Druid
    module Realtime

      def realtime_spec(zk_host, max_rows, partition_num)

        require 'ruby_dig'

        specs = {}

        rb_monitor = {}
        rb_monitor["dataSource"] = "rb_monitor"
        rb_monitor["dimensions"] = []
        rb_monitor["dimensionExclusions"] = ["unit", "type", "value"]
        rb_monitor["metrics"] = [
          {"type" => "count", "name" => "events"},
          {"type" => "doubleSum", "fieldName" => "value", "name" => "sum_value"},
          {"type" => "doubleMax", "fieldName" => "value", "name" => "max_value"},
          {"type" => "doubleMin", "fieldName" => "value", "name" => "min_value"}
        ]
        rb_monitor["feed"] = "rb_monitor"

        rb_state = {}
        rb_state["dataSource"] = "rb_state"
        rb_state["dimensions"] = ["wireless_station", "type", "wireless_channel", "wireless_tx_power", "wireless_admin_state", "wireless_op_state", "wireless_mode", "wireless_slot", "sensor_name", "sensor_uuid", "deployment", "deployment_uuid", "namespace", "namespace_uuid", "organizaton", "organization_uuid", "market", "market_uuid", "floor", "floor_uuid", "zone", "zone_uuid", "building", "building_uuid", "campus", "campus_uuid", "service_provider", "service_provider_uuid", "wireless_station_ip", "status", "wireless_station_name"]
        rb_state["dimensionExclusions"] = []
        rb_state["metrics"] = [
          {"type" => "count", "name" => "events"},
          {"type" => "doubleSum", "fieldName" => "value", "name" => "sum_value"},
          {"type" => "hyperUnique", "fieldName" => "wireless_station", "name" => "wireless_stations"},
          {"type" => "hyperUnique", "fieldName" => "wireless_channel", "name" => "wireless_channels"},
          {"type" => "longSum", "fieldName" => "wireless_tx_power", "name" => "sum_wireless_tx_power"}
        ]
        rb_state["feed"] = "rb_state"

        rb_flow = {}
        rb_flow["dataSource"] = "rb_flow"
        rb_flow["dimensions"] = ["application_id_name", "building", "building_uuid", "campus", "campus_uuid", "client_accounting_type", "client_id", "client_latlong", "client_mac", "client_mac_vendor", "client_rssi", "conversation", "coordinates_map", "deployment", "deployment_uuid", "direction", "dot11_protocol", "dot11_status", "http_social_media", "engine_id_name", "product_name", "floor", "floor_uuid", "host", "host_l2_domain", "http_user_agent", "ip_protocol_version", "l4_proto", "lan_interface_name", "lan_interface_description", "lan_ip", "lan_ip_net_name", "lan_l4_port", "lan_name", "lan_vlan", "market", "market_uuid", "namespace", "namespace_uuid", "organization", "organization_uuid", "referer", "referer_l2", "scatterplot", "selector_name", "sensor_name", "sensor_uuid", "service_provider", "service_provider_uuid", "tcp_flags", "tos", "type", "url", "wan_interface_name", "wan_interface_description", "wan_ip", "wan_ip_as_name", "wan_ip_country_code", "wan_ip_map", "wan_ip_net_name", "wan_l4_port", "wan_name", "wan_vlan", "wireless_id", "wireless_station", "zone", "ip_country_code", "public_ip_mac", "lan_ip_name"]
        rb_flow["dimensionExclusions"] = ["bytes", "pkts", "flow_end_reason", "first_switched", "wan_ip_name"]
        rb_flow["metrics"] = [
          {"type" => "count", "name" => "events"},
          {"type" => "hyperUnique", "fieldName" => "msg", "name" => "signatures"},
          {"type" => "longSum", "fieldName" => "darklist_score", "name" => "sum_dl_score"}
        ]
        rb_flow["feed"] = "rb_flow"

        rb_event = {}
        rb_event["dataSource"] = "rb_event"
        rb_event["dimensions"] = ["src", "dst", "src_port", "dst_port", "src_as_name", "src_country_code", "dst_map", "src_map", "service_provider", "sha256", "file_uri", "file_size", "file_hostname", "action", "ethlength_range", "icmptype", "ethsrc", "ethsrc_vendor", "ethdst", "ethdst_vendor", "ttl", "vlan", "classification", "domain_name", "group_name", "sig_generator", "rev", "priority", "msg", "sig_id", "dst_country_code", "dst_as_name", "namespace", "deployment", "market", "organization", "campus", "building", "floor", "floor_uuid", "conversation", "iplen_range", "l4_proto", "sensor_name", "scatterplot", "src_net_name", "dst_net_name", "tos", "service_provider_uuid", "namespace_uuid", "market_uuid", "organization_uuid", "campus_uuid", "building_uuid", "deployment_uuid"]
        rb_event["dimensionExclusions"] = ["payload"]
        rb_event["metrics"] = [
          {"type" => "count", "name" => "events"},
          {"type" => "longSum", "fieldName" => "bytes", "name" => "sum_bytes"},
          {"type" => "longSum", "fieldName" => "pkts", "name" => "sum_pkts"},
          {"type" => "longSum", "fieldName" => "client_rssi_num", "name" => "sum_rssi"},
          {"type" => "hyperUnique", "fieldName" => "client_mac", "name" => "clients"},
          {"type" => "hyperUnique", "fieldName" => "wireless_station", "name" => "wireless_stations"}
        ]
        rb_event["feed"] = "rb_event"

        rb_social = {}
        rb_social["dataSource"] = "rb_social"
        rb_social["dimensions"] = ["client_latlong", "lan_ip_country_code", "sensor_uuid", "deployment", "deployment_uuid", "namespace", "namespace_uuid", "user_screen_name", "user_name", "user_id", "type", "hashtags", "mentions", "msg", "sentiment", "msg_send_from", "user_from", "user_profile_img_https", "influence", "picture_url", "language", "category", "followers", "floor", "floor_uuid", "campus", "campus_uuid", "building", "building_uuid", "service_provider", "service_provider_uuid", "market", "market_uuid", "organization", "organization_uuid", "sensor_name"]
        rb_social["dimensionExclusions"] = ["user_msgs"]
        rb_social["metrics"] = [
          {"type" => "count", "name" => "events"},
          {"type" => "longSum", "name" => "sum_followers", "fieldName" => "followers"},
          {"type" => "hyperUnique", "name" => "users", "fieldName" => "user_screen_name"}
        ]
        rb_social["feed"] = "rb_social"

        rb_hashtag = {}
        rb_hashtag["dataSource"] = "rb_hashtag"
        rb_hashtag["dimensions"] = ["type", "value", "sensor_name", "sensor_uuid", "floor", "floor_uuid", "building", "building_uuid", "campus", "campus_uuid", "market", "market_uuid", "organization", "organization_uuid", "service_provider", "service_provider_uuid", "deployment", "deployment_uuid", "namespace", "namespace_uuid"]
        rb_hashtag["dimensionExclusions"] = []
        rb_hashtag["metrics"] = [
          {"type" => "count", "name" => "events"}
        ]
        rb_hashtag["feed"] = "rb_hashtag"

        rb_iot = {}
        rb_iot["dataSource"] = "rb_iot"
        rb_iot["dimensions"] = ["sensor_uuid", "monitor", "value", "proxy_uuid", "deployment", "deployment_uuid", "namespace", "namespace_uuid", "market", "market_uuid", "organization", "organization_uuid", "client_latlong", "coordinates_map", "campus", "campus_uuid", "building", "building_uuid", "floor", "floor_uuid"]
        rb_iot["dimensionExclusions"] = []
        rb_iot["metrics"] = [
          {"type" => "count", "name" => "events"},
          {"type" => "doubleSum", "fieldName" => "value", "name" => "sum_value"},
          {"type" => "doubleMax", "fieldName" => "value", "name" => "max_value"},
          {"type" => "doubleMin", "fieldName" => "value", "name" => "min_value"}
        ]
        rb_iot["feed"] = "rb_iot"

        rb_vault = {}
        rb_vault["dataSource"] = "rb_vault"
        rb_vault["dimensions"] = ["pri", "pri_text", "syslogfacility", "syslogfacility_text", "syslogseverity", "syslogseverity_text", "hostname", "fromhost_ip", "app_name", "sensor_name", "proxy_uuid", "message", "status", "category", "source", "target", "sensor_uuid", "service_provider_uuid", "namespace_uuid", "deployment_uuid", "market_uuid", "organization_uuid", "campus_uuid", "building_uuid", "floor_uuid", "action"]
        rb_vault["dimensionExclusions"] = ["unit", "type", "valur"]
        rb_vault["metrics"] = [
          {"type" => "count", "name" => "events"}
        ]
        rb_vault["feed"] = "rb_vault_post"

        specs["specs"] = [rb_monitor, rb_state, rb_flow, rb_event, rb_social, rb_hashtag, rb_iot, rb_vault]
        #specs["specs"] = [rb_monitor]

        realtime_spec = []

        specs["specs"].each { |spec|

          # dataSchema section
          data_schema = {}
          data_schema["dataSource"] = spec["dataSource"]
          data_schema["parser"] = {}
          data_schema["parser"]["type"] = "string"
          data_schema["parser"]["parseSpec"] = {}
          data_schema["parser"]["parseSpec"]["type"] = "jsonLowercase"
          data_schema["parser"]["parseSpec"]["format"] = "json"
          data_schema["parser"]["parseSpec"]["timestampSpec"] = {}
          data_schema["parser"]["parseSpec"]["timestampSpec"]["column"] = "timestamp"
          data_schema["parser"]["parseSpec"]["timestampSpec"]["format"] = "ruby"
          data_schema["parser"]["parseSpec"]["dimensionSpec"] = {}
          data_schema["parser"]["parseSpec"]["dimensionSpec"]["dimensions"] = spec["dimensions"]
          data_schema["parser"]["parseSpec"]["dimensionSpec"]["dimensionExclusions"] = spec["dimensionExclusions"]
          data_schema["metricsSpec"] = spec["metrics"]
          data_schema["granularitySpec"] = {}
          data_schema["granularitySpec"]["type"] = "uniform"
          data_schema["granularitySpec"]["segmentGranularity"] = "HOUR"
          data_schema["granularitySpec"]["queryGranularity"] = "MINUTE"

          # ioConfig section
          io_config = {}
          io_config["type"] = "realtime"
          io_config["firehose"] = {}
          io_config["firehose"]["type"] = "kafka-0.8"
          io_config["firehose"]["consumerProps"] = {}
          io_config["firehose"]["consumerProps"]["zookeeper.connect"] = zk_host
          io_config["firehose"]["consumerProps"]["zookeeper.connection.timeout.ms"] = "15000"
          io_config["firehose"]["consumerProps"]["zookeeper.session.timeout.ms"] = "15000"
          io_config["firehose"]["consumerProps"]["zookeeper.sync.time.ms"] = "5000"
          io_config["firehose"]["consumerProps"]["rebalance.max.retries"] = "4"
          io_config["firehose"]["consumerProps"]["group.id"] = "rb-group"
          io_config["firehose"]["consumerProps"]["fetch.message.max.bytes"] = "1048576"
          io_config["firehose"]["consumerProps"]["auto.offset.reset"] = "largest"
          io_config["firehose"]["consumerProps"]["auto.commit.enable"] = "true"
          io_config["firehose"]["feed"] = spec["feed"]
          io_config["plumber"] = {}
          io_config["plumber"]["type"] = "realtime"

          # tuningConfig section
          tuning_config = {}
          tuning_config["type"] = "realtime"
          tuning_config["maxRowsInMemory"] = max_rows
          tuning_config["intermediatePersistPeriod"] = "PT20m"
          tuning_config["windowPeriod"] = "PT30m"
          tuning_config["basePersistDirectory"] = "/tmp/realtime"
          tuning_config["shardSpec"] = {}
          tuning_config["shardSpec"]["type"] = "linear"
          tuning_config["shardSpec"]["partitionNum"] = partition_num
          tuning_config["rejectionPolicy"] = {}
          tuning_config["rejectionPolicy"]["type"] = "serverTime"

          realtime_spec << {
            "dataSchema" => data_schema,
            "ioConfig" => io_config,
            "tuningConfig" => tuning_config
          }

        }# End specs each loop

        return realtime_spec

      end
    end
end

module Druid
  module Realtime
    def realtime_spec(dimensions, zk_host, max_rows, partition_num, namespaces)
      namespaces.push('')
      namespaces.uniq!
      specs = {}

      rb_monitor_array = []
      namespaces.each do |namespace|
        rb_monitor = {}
        rb_monitor['dataSource'] = 'rb_monitor'
        rb_monitor['dataSource'] += '_' + namespace unless namespace.empty?
        rb_monitor['dimensionExclusions'] = %w(unit type value)
        rb_monitor['metrics'] = [
          { type: 'count', name: 'events' },
          { type: 'doubleSum', fieldName: 'value', name: 'sum_value' },
          { type: 'doubleMax', fieldName: 'value', name: 'max_value' },
          { type: 'doubleMin', fieldName: 'value', name: 'min_value' },
        ]
        rb_monitor['feed'] = 'rb_monitor'
        rb_monitor['feed'] += '_post' if namespaces.count > 1
        rb_monitor['feed'] += '_' + namespace unless namespace.empty?
        rb_monitor_array.push(rb_monitor)
      end

      rb_state_array = []
      namespaces.each do |namespace|
        rb_state = {}
        rb_state['dataSource'] = 'rb_state'
        rb_state['dataSource'] += '_' + namespace unless namespace.empty?
        rb_state['dimensions'] = %w(wireless_station type wireless_channel wireless_tx_power wireless_admin_state wireless_op_state wireless_mode wireless_slot sensor_name sensor_uuid deployment deployment_uuid namespace namespace_uuid organizaton organization_uuid market market_uuid floor floor_uuid zone zone_uuid building building_uuid campus campus_uuid service_provider service_provider_uuid wireless_station_ip status wireless_station_name client_count)
        rb_state['dimensionExclusions'] = []
        rb_state['metrics'] = [
          { type: 'count', name: 'events' },
          { type: 'doubleSum', fieldName: 'value', name: 'sum_value' },
          { type: 'hyperUnique', fieldName: 'wireless_station', name: 'wireless_stations' },
          { type: 'hyperUnique', fieldName: 'wireless_channel', name: 'wireless_channels' },
          { type: 'longSum', fieldName: 'wireless_tx_power', name: 'sum_wireless_tx_power' },
        ]
        rb_state['feed'] = 'rb_state_post'
        rb_state['feed'] += '_' + namespace unless namespace.empty?
        rb_state_array.push(rb_state)
      end

      rb_flow_array = []
      namespaces.each do |namespace|
        rb_flow = {}
        rb_flow['dataSource'] = 'rb_flow'
        rb_flow['dataSource'] += '_' + namespace unless namespace.empty?
        rb_flow['dimensions'] = %w(application_id_name building building_uuid campus campus_uuid client_accounting_type client_auth_type client_fullname client_gender client_id client_latlong client_loyality client_mac client_mac_vendor client_rssi client_vip conversation coordinates_map darklist_category darklist_direction darklist_score_name darklist_score deployment deployment_uuid direction dot11_protocol dot11_status dst_map duration engine_id_name floor floor_uuid host host_l2_domain http_social_media http_user_agent https_common_name interface_name ip_as_name ip_country_code ip_protocol_version l4_proto lan_interface_description lan_interface_name lan_ip lan_ip_as_name lan_ip_country_code lan_ip_name lan_ip_net_name lan_l4_port lan_name lan_vlan market market_uuid namespace namespace_uuid organization organization_uuid product_name public_ip public_ip_mac referer referer_l2 scatterplot selector_name sensor_ip sensor_name sensor_uuid service_provider service_provider_uuid src_map tcp_flags tos type url wan_interface_description wan_interface_name wan_ip wan_ip_as_name wan_ip_country_code wan_ip_map wan_ip_net_name wan_l4_port wan_name wan_vlan wireless_id wireless_operator wireless_station zone zone_uuid)
        rb_flow['dimensionExclusions'] = %w(bytes pkts flow_end_reason first_switched wan_ip_name)
        rb_flow['metrics'] = [
          { type: 'count', name: 'events' },
          { type: 'longSum', fieldName: 'bytes', name: 'sum_bytes' },
          { type: 'longSum', fieldName: 'pkts', name: 'sum_pkts' },
          { type: 'longSum', fieldName: 'client_rssi_num', name: 'sum_rssi' },
          { type: 'hyperUnique', fieldName: 'client_mac', name: 'clients' },
          { type: 'hyperUnique', fieldName: 'wireless_station', name: 'wireless_stations' },
          { type: 'longSum', fieldName: 'darklist_score', name: 'sum_dl_score' },
        ]
        rb_flow['feed'] = 'rb_flow_post'
        rb_flow['feed'] += '_' + namespace unless namespace.empty?
        rb_flow_array.push(rb_flow)
      end

      rb_event_array = []
      namespaces.each do |namespace|
        rb_event = {}
        rb_event['dataSource'] = 'rb_event'
        rb_event['dataSource'] += '_' + namespace unless namespace.empty?
        rb_event['dimensions'] = %w(src dst src_port dst_port src_as_name src_country_code dst_map src_map service_provider sha256 file_uri file_size file_hostname action ethlength_range icmptype ethsrc ethsrc_vendor ethdst ethdst_vendor ttl vlan classification domain_name group_name sig_generator rev priority msg sig_id dst_country_code dst_as_name namespace deployment market organization campus building floor floor_uuid conversation iplen_range l4_proto sensor_name sensor_uuid scatterplot src_net_name dst_net_name tos service_provider_uuid namespace_uuid market_uuid organization_uuid campus_uuid building_uuid deployment_uuid darklist_category darklist_direction darklist_score_name darklist_score incident_uuid)
        rb_event['dimensionExclusions'] = ['payload']
        rb_event['metrics'] = [
          { type: 'count', name: 'events' },
          { type: 'hyperUnique', fieldName: 'msg', name: 'signatures' },
          { type: 'longSum', fieldName: 'darklist_score', name: 'sum_dl_score' },
        ]
        rb_event['feed'] = 'rb_event_post'
        rb_event['feed'] += '_' + namespace unless namespace.empty?
        rb_event_array.push(rb_event)
      end

      rb_iot = {}
      rb_iot['dataSource'] = 'rb_iot'
      rb_iot['dimensions'] = %w(sensor_uuid monitor value proxy_uuid deployment deployment_uuid namespace namespace_uuid market market_uuid organization organization_uuid client_latlong coordinates_map campus campus_uuid building building_uuid floor floor_uuid)
      rb_iot['dimensionExclusions'] = []
      rb_iot['metrics'] = [
        { type: 'count', name: 'events' },
        { type: 'doubleSum', fieldName: 'value', name: 'sum_value' },
        { type: 'doubleMax', fieldName: 'value', name: 'max_value' },
        { type: 'doubleMin', fieldName: 'value', name: 'min_value' },
      ]
      rb_iot['feed'] = 'rb_iot'

      rb_vault_array = []
      namespaces.each do |namespace|
        rb_vault = {}
        rb_vault['dataSource'] = 'rb_vault'
        rb_vault['dataSource'] += '_' + namespace unless namespace.empty?
        rb_vault['dimensions'] = %w(pri pri_text syslogfacility syslogfacility_text syslogseverity syslogseverity_text hostname fromhost_ip app_name sensor_name proxy_uuid message status category source target sensor_uuid service_provider service_provider_uuid namespace namespace_uuid deployment deployment_uuid market market_uuid organization organization_uuid campus campus_uuid building building_uuid floor floor_uuid action incident_uuid alarm_id alarm_name alarm_product_type alarm_condition alarm_user alarm_severity) + dimensions.keys
        rb_vault['dimensionExclusions'] = %w(unit type valur)
        rb_vault['metrics'] = [
          { type: 'count', name: 'events' },
        ]
        rb_vault['feed'] = 'rb_vault_post'
        rb_vault['feed'] += '_' + namespace unless namespace.empty?
        rb_vault_array.push(rb_vault)
      end

      # Scanner
      rb_scanner_array = []
      namespaces.each do |namespace|
        rb_scanner = {}
        rb_scanner['dataSource'] = 'rb_scanner'
        rb_scanner['dataSource'] += '_' + namespace unless namespace.empty?
        rb_scanner['dimensions'] = %w(pri pri_text syslogfacility syslogfacility_text syslogseverity syslogseverity_text hostname fromhost_ip app_name sensor_name proxy_uuid message status category source target sensor_uuid service_provider service_provider_uuid namespace namespace_uuid deployment deployment_uuid market market_uuid organization organization_uuid campus campus_uuid building building_uuid floor floor_uuid ipaddress scan_id scan_subtype scan_type result_data result cve_info vendor product version servicename protocol cpe cve port metric severity score mac subnet path layer ipv4 port_state)
        rb_scanner['dimensionExclusions'] = []
        rb_scanner['metrics'] = [
          { type: 'count', name: 'events' },
        ]
        rb_scanner['feed'] = 'rb_scanner_post'
        rb_scanner['feed'] += '_' + namespace unless namespace.empty?
        rb_scanner_array.push(rb_scanner)
      end

      # Location
      rb_location_array = []
      namespaces.each do |namespace|
        rb_location = {}
        rb_location['dataSource'] = 'rb_location'
        rb_location['dataSource'] += '_' + namespace unless namespace.empty?
        rb_location['dimensions'] = %w(client_mac sensor_name sensor_uuid deployment deployment_uuid namespace namespace_uuid type floor floor_uuid zone zone_uuid campus campus_uuid building building_uuid wireless_station floor_old floor_new zone_old zone_new wireless_station_old wireless_station_new building_old building_new campus_old campus_new service_provider service_provider_uuid new old transition organization_uuid market_uuid client_latlong dot11_status client_profile client_mac_vendor)
        rb_location['dimensionExclusions'] = []
        rb_location['metrics'] = [
          { type: 'count', name: 'events' },
          { type: 'hyperUnique', name: 'clients', fieldName: 'client_mac' },
          { type: 'longSum', name: 'sum_dwell_time', fieldName: 'dwell_time' },
          { type: 'longSum', name: 'sum_rssi', fieldName: 'client_rssi_num' },
          { type: 'doubleSum', name: 'sum_popularity', fieldName: 'popularity' },
          { type: 'longSum', name: 'sum_repetitions', fieldName: 'repetitions' },
          { type: 'hyperUnique', name: 'sessions', fieldName: 'session' },
          { type: 'approxHistogramFold', name: 'hist_dwell', fieldName: 'dwell_time', resolution: 50, numBuckets: 30, lowerLimit: 3, upperLimit: 1440 },
        ]
        rb_location['feed'] = 'rb_loc_post'
        rb_location['feed'] += '_' + namespace unless namespace.empty?
        rb_location_array.push(rb_location)
      end

      # Wireless
      rb_wireless_array = []
      namespaces.each do |namespace|
        rb_wireless = {}
        rb_wireless['dataSource'] = 'rb_wireless'
        rb_wireless['dataSource'] += '_' + namespace unless namespace.empty?
        rb_wireless['dimensions'] = %w(zone_uuid client_profile floor_uuid service_provider building_uuid client_rssi_num sensor_uuid namespace_uuid floor campus sensor_name client_mac client_latlong type organization wireless_station zone building client_rssi namespace dot11_status service_provider_uuid campus_uuid organization_uuid client_mac_vendor)
        rb_wireless['dimensionExclusions'] = []
        rb_wireless['metrics'] = [
          { type: 'count', name: 'events' },
          { type: 'hyperUnique', name: 'clients', fieldName: 'client_mac' },
        ]
        rb_wireless['feed'] = 'rb_wireless'
        rb_wireless['feed'] += '_' + namespace unless namespace.empty?
        rb_wireless_array.push(rb_wireless)
      end

      # BI
      rb_bi = {}
      rb_bi['dataSource'] = 'rb_bi'
      rb_bi['dimensions'] = %w(organization_id organization_name question_id question questionnaire_name questionnaire_id feedback_id answer_id answer client_id client_latlong client_name client_country client_age client_email client_gender sensor_uuid sensor_name service_provider service_provider_uuid namespace namespace_uuid deployment deployment_uuid market market_uuid organization organization_uuid campus campus_uuid building building_uuid floor floor_uuid)
      rb_bi['dimensionExclusions'] = []
      rb_bi['metrics'] = [
        { type: 'count', name: 'events' },
      ]
      rb_bi['feed'] = 'rb_bi_post'

      specs['specs'] = rb_flow_array + rb_vault_array + rb_scanner_array + rb_location_array + rb_wireless_array + rb_monitor_array + rb_state_array + rb_event_array + [rb_iot, rb_bi]
      # specs['specs'] = [rb_monitor]
      realtime_spec = []

      specs['specs'].each do |spec|
        # dataSchema section
        data_schema = {}
        data_schema['dataSource'] = spec['dataSource']
        data_schema['parser'] = {}
        data_schema['parser']['type'] = 'string'
        data_schema['parser']['parseSpec'] = {}
        data_schema['parser']['parseSpec']['type'] = 'jsonLowercase'
        data_schema['parser']['parseSpec']['format'] = 'json'
        data_schema['parser']['parseSpec']['timestampSpec'] = {}
        data_schema['parser']['parseSpec']['timestampSpec']['column'] = 'timestamp'
        data_schema['parser']['parseSpec']['timestampSpec']['format'] = 'ruby'
        data_schema['parser']['parseSpec']['dimensionsSpec'] = {}
        data_schema['parser']['parseSpec']['dimensionsSpec']['dimensions'] = spec['dimensions']
        data_schema['parser']['parseSpec']['dimensionsSpec']['dimensionExclusions'] = spec['dimensionExclusions']
        data_schema['metricsSpec'] = spec['metrics']
        data_schema['granularitySpec'] = {}
        data_schema['granularitySpec']['type'] = 'uniform'
        data_schema['granularitySpec']['segmentGranularity'] = 'HOUR'
        data_schema['granularitySpec']['queryGranularity'] = 'MINUTE'

        # ioConfig section
        io_config = {}
        io_config['type'] = 'realtime'
        io_config['firehose'] = {}
        io_config['firehose']['type'] = 'kafka-0.8'
        io_config['firehose']['consumerProps'] = {}
        io_config['firehose']['consumerProps']['zookeeper.connect'] = zk_host
        io_config['firehose']['consumerProps']['zookeeper.connection.timeout.ms'] = '15000'
        io_config['firehose']['consumerProps']['zookeeper.session.timeout.ms'] = '15000'
        io_config['firehose']['consumerProps']['zookeeper.sync.time.ms'] = '5000'
        io_config['firehose']['consumerProps']['rebalance.max.retries'] = '4'
        io_config['firehose']['consumerProps']['group.id'] = 'rb-group'
        io_config['firehose']['consumerProps']['fetch.message.max.bytes'] = '1048576'
        io_config['firehose']['consumerProps']['auto.offset.reset'] = 'largest'
        io_config['firehose']['consumerProps']['auto.commit.enable'] = 'true'
        io_config['firehose']['feed'] = spec['feed']
        io_config['plumber'] = {}
        io_config['plumber']['type'] = 'realtime'

        # tuningConfig section
        tuning_config = {}
        tuning_config['type'] = 'realtime'
        tuning_config['maxRowsInMemory'] = max_rows
        tuning_config['intermediatePersistPeriod'] = 'PT20m'
        tuning_config['windowPeriod'] = 'PT30m'
        tuning_config['basePersistDirectory'] = '/tmp/realtime'
        tuning_config['shardSpec'] = {}
        tuning_config['shardSpec']['type'] = 'linear'
        tuning_config['shardSpec']['partitionNum'] = partition_num
        tuning_config['rejectionPolicy'] = {}
        tuning_config['rejectionPolicy']['type'] = 'serverTime'

        realtime_spec << {
          dataSchema: data_schema,
          ioConfig: io_config,
          tuningConfig:  tuning_config,
        }
      end # End specs each loop

      realtime_spec
    end
  end
end

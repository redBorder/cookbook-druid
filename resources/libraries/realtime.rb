module Druid
    module Realtime

      def realtime_hash()

        require 'ruby_dig'

        ingestion_spec = []

        # dataSchema section
        data_schema = {}
        data_schema["datasource"] = DATASOURCE HERE!!!!
        data_schema["parser"] = {}
        data_schema["parser"]["type"] = "string"
        data_schema["parser"]["parseSpec"] = {}
        data_schema["parser"]["parseSpec"]["type"] = "jsonLowercase"
        data_schema["parser"]["parseSpec"]["format"] = "json"
        data_schema["parser"]["parseSpec"]["timestampSpec"] = {}
        data_schema["parser"]["parseSpec"]["timestampSpec"]["column"] = "timestamp"
        data_schema["parser"]["parseSpec"]["timestampSpec"]["format"] = "ruby"
        data_schema["parser"]["parseSpec"]["dimensionSpec"] = {}
        data_schema["parser"]["parseSpec"]["dimensionSpec"]["dimensions"] = [] # DIMENSIONS HERE!!!
        data_schema["parser"]["parseSpec"]["dimensionSpec"]["dimensionExclusions"] = [] # DIMENSION EXCLUSIONS HERE!!!
        data_schema["metricSpec"] = []
        data_schema["granularitySpec"] = {}
        data_schema["granularitySpec"]["type"] = "uniform"
        data_schema["granularitySpec"]["segmentGranularity"] = "HOUR"
        data_schema["granularitySpec"]["queryGranularity"] =

        # ioConfig section
        io_config = {}
        io_config["type"] = "realtime"
        io_config["firehose"] = {}
        io_config["firehose"]["type"] = "kafka-0.8"
        io_config["firehose"]["consumerProps"] = {}
        io_config["firehose"]["consumerProps"]["zookeeper.connect"] = VARIABLE HERE!!!!!
        io_config["firehose"]["consumerProps"]["zookeeper.connection.timeout.ms"] = "15000"
        io_config["firehose"]["consumerProps"]["zookeeper.session.timeout.ms"] = "15000"
        io_config["firehose"]["consumerProps"]["zookeeper.sync.time.ms"] = "5000"
        io_config["firehose"]["consumerProps"]["rebalance.max.retries"] = "4"
        io_config["firehose"]["consumerProps"]["group.id"] = "rb-group"
        io_config["firehose"]["consumerProps"]["fetch.message.max.bytes"] = "1048576"
        io_config["firehose"]["consumerProps"]["auto.offset.reset"] = "largest"
        io_config["firehose"]["consumerProps"]["auto.commit.enable"] = "true"
        io_config["firehose"]["feed"] = TOPIC HERE!!!!
        io_config["plumber"] = {}
        io_config["plumber"]["type"] = "realtime"

        # tunningConfig section
        tunning_config = {}
        tunning_config["type"] = "realtime"
        tunning_config["maxRowsInMemory"] = MAX ROWS HERE!!!!
        tunning_config["intermediatePersistPeriod"] = "PT20m"
        tunning_config["windowPeriod"] = "PT30m"
        tunning_config["basePersistDirectory"] = "/tmp/realtime"
        tunning_config["shardSpec"] = {}
        tunning_config["shardSpec"]["type"] = "linear"
        tunning_config["shardSpec"]["partitionNum"] = PARTITIONS HERE!!!!
        tunning_config["rejectionPolicy"] = {}
        tunning_config["rejectionPolicy"]["type"] = "serverTime"

      end
    end
end

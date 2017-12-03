class Xmonitor::Printer
  def self.start(argv)
    config_file = argv[0]

    config = Xmonitor::Config.from_yaml(config_file)

    server = self.new(config)

    server.run
  end

  def initialize(config)
    @config = config
    @logger = Logger.new(STDERR)
  end

  def run
    init_aws_config_and_clients

    query_execution_response = start_query_execution(all_metrics_by_hour_query)

    query_execution_id = query_execution_response.query_execution_id
    @logger.info(query_execution_id: query_execution_id)

    last_get_query_execution_response = wait_for_finish_query_execution(query_execution_id)

    output_location = last_get_query_execution_response.query_execution.result_configuration.output_location
    @logger.info(output_location: output_location)

    get_s3_object_and_process_body(output_location) do |body|
      CSV.new(body, headers: true).each{|row|
        puts [Time.parse(row[0]), row[1], row[2], row[3], row[4].to_f].to_csv
      }
    end
  rescue StandardError => e
    @logger.error(error: e, backtrace: e.backtrace)
  end

  def init_aws_config_and_clients
    Aws.config[:credentials] = Aws::Credentials.new(@config.access_key_id, @config.secret_access_key)

    @athena = Aws::Athena::Client.new(region: @config.region)
    @s3 = Aws::S3::Client.new(region: @config.region)
  end

  def all_metrics_by_hour_query
    'SELECT DATE_FORMAT(timestamp, \'%Y-%m-%d %H:00:00\') AS _timestamp, host AS _host, metric AS _metric, dimension AS _dimension, AVG(value) AS _value FROM "' + @config.athena_database + '"."' + @config.athena_table_name + '" GROUP BY DATE_FORMAT(timestamp, \'%Y-%m-%d %H:00:00\'), host, metric, dimension ORDER BY _host, _metric, _dimension, _timestamp DESC;'
  end

  def start_query_execution(query_string)
    @athena.start_query_execution(
      query_string: query_string,
      query_execution_context: {database: @config.athena_database},
      result_configuration: {output_location: "s3://#{@config.athena_s3_bucket}/"}
    ).tap{|response|
      @logger.info(response: response)
    }
  end

  def wait_for_finish_query_execution(query_execution_id)
    loop do
      response = @athena.get_query_execution(query_execution_id: query_execution_id)

      @logger.info(response: response)

      state = response.query_execution.status.state
      
      return response unless ['QUEUED', 'RUNNING'].include?(state)

      sleep 1
    end
  end

  def get_s3_object_and_process_body(s3_object_arn, &blk)
    _, bucket, key = s3_object_arn.match(/s3:\/\/(.+?)\/(.+)$/).to_a

    yield @s3.get_object(bucket: bucket, key: key).body
  end
end

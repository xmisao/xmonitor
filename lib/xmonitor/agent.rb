class Xmonitor::Agent
  NEW_LINE = "\n"
  TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

  class GrabError < StandardError; end
  class PutError < StandardError; end

  def self.start(argv)
    config_file = argv[0]

    config = Xmonitor::Config.from_yaml(config_file)

    agent = self.new(config)

    agent.run
  end

  def initialize(config)
    @hostname = Socket.gethostname
    @config = config
    @logger = Logger.new(STDOUT)
  end

  def run
    init_aws_config

    loop do
      with_log 'monitor' do
        monitor
      end

      with_log 'sleep', true do
        sleep 60
      end
    end
  end

  def with_log(description, raise_exception = false)
    @logger.info("Begin #{description}")
    begin
      yield
    rescue => e
      if raise_exception
        raise e
      else
        @logger.error(e)
      end
    ensure
      @logger.info("End #{description}")
    end
  end

  def init_aws_config
    Aws.config[:credentials] = Aws::Credentials.new(@config.access_key_id, @config.secret_access_key)
  end

  def monitor
    records = grab

    raise GrabError if records.empty?

    data = records.join(NEW_LINE) + NEW_LINE

    put_to_firehose(data)
  end

  def grab
    grab_cpu + grab_memory + grab_disks + grab_network
  rescue => e
    raise GrabError.new(e)
  end

  def grab_cpu
    PosixPsutil::CPU.cpu_times_percent(1, false).each_pair.map{|(k, v)|
      create_record('cpu', k, v)
    }
  end

  def grab_memory
    PosixPsutil::Memory.virtual_memory.each_pair.map{|(k, v)|
      create_record('memory', k, v)
    }
  end

  def grab_disks
    grab_disks_usage + grab_disks_io_counter
  end

  def grab_disks_usage
    devices = PosixPsutil::Disks.disk_partitions.map{|partition| partition.device}

    devices.map{|device|
      PosixPsutil::Disks.disk_usage(device).each_pair.map{|(k, v)|
        metric = "#{device}.#{k}"
        create_record('disks', metric, v)
      }
    }.flatten
  end

  def grab_disks_io_counter
    PosixPsutil::Disks.disk_io_counters.each_pair.map{|(k, v)|
      disk = k

      v.each_pair.map{|k2, v2|
        metric = "#{disk}.#{k2}"
        create_record('disks', metric, v2)
      }
    }.flatten
  end

  def grab_network
    grab_net_io_counter
  end

  def grab_net_io_counter
    PosixPsutil::Network.net_io_counters(true).each_pair.map{|(k, v)|
      interface = k

      v.each_pair.map{|k2, v2|
        metric = "#{interface}.#{k2}"
        create_record('network', metric, v2)
      }
    }.flatten
  end

  def create_record(metric, dimension, value)
    {timestamp: Time.now.strftime(TIME_FORMAT), host: @hostname, metric: metric, dimension: dimension, value: value}.to_json
  end

  def put_to_firehose(data)
    client = Aws::Firehose::Client.new(region: @config.region)

    client.put_record({
      delivery_stream_name: @config.stream_name,
      record: {
        data: data,
      },
    })
  rescue => e
    raise PutError.new(e)
  end
end

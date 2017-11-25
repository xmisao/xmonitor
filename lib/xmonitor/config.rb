class Xmonitor::Config
  attr_reader :region, :stream_name, :access_key_id, :secret_access_key, 

  KEY_REGION = 'region'
  KEY_STREAM_NAME = 'stream_name'
  KEY_ACCESS_KEY_ID = 'access_key_id'
  KEY_SECRET_ACCESS_KEY = 'secret_access_key'

  def self.from_yaml(path)
    json = YAML.load(File.read(path))

    self.new(json[KEY_REGION], json[KEY_STREAM_NAME], json[KEY_ACCESS_KEY_ID], json[KEY_SECRET_ACCESS_KEY])
  end

  def initialize(*args)
    @region, @stream_name, @access_key_id, @secret_access_key = *args
  end
end

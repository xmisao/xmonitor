class Xmonitor::Config
  attr_reader :region, :stream_name, :access_key_id, :secret_access_key, :athena_database, :athena_s3_bucket, :athena_table_name

  KEY_REGION = 'region'
  KEY_STREAM_NAME = 'stream_name'
  KEY_ACCESS_KEY_ID = 'access_key_id'
  KEY_SECRET_ACCESS_KEY = 'secret_access_key'
  KEY_ATHENA_DATABASE = 'athena_database'
  KEY_ATHENA_S3_BUCKET = 'athena_s3_bucket'
  KEY_ATHENA_TABLE_NAME = 'athena_table_name'

  def self.from_yaml(path)
    yaml = YAML.load(File.read(path))

    self.new(yaml[KEY_REGION], yaml[KEY_STREAM_NAME], yaml[KEY_ACCESS_KEY_ID], yaml[KEY_SECRET_ACCESS_KEY], yaml[KEY_ATHENA_DATABASE], yaml[KEY_ATHENA_S3_BUCKET], yaml[KEY_ATHENA_TABLE_NAME])
  end

  def initialize(*args)
    @region, @stream_name, @access_key_id, @secret_access_key, @athena_database, @athena_s3_bucket, @athena_table_name = *args
  end
end

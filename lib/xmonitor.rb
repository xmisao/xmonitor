require "xmonitor/version"

module Xmonitor
  require "socket"
  require "logger"
  require "yaml"
  require "json"
  require "irb"

  require "posixpsutil"
  require "aws-sdk-firehose"

  require "xmonitor/config"
  require "xmonitor/agent"
end

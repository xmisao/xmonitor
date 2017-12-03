require "xmonitor/version"

module Xmonitor
  require "socket"
  require "logger"
  require "yaml"
  require "json"
  require "irb"
  require "csv"

  require "posixpsutil"
  require "aws-sdk-firehose"
  require "aws-sdk-athena"
  require "aws-sdk-s3"

  require "xmonitor/config"
  require "xmonitor/agent"

  autoload :Printer, 'xmonitor/printer'
  autoload :Dashboard, 'xmonitor/dashboard'
end

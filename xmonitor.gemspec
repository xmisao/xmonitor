# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xmonitor/version"

Gem::Specification.new do |spec|
  spec.name          = "xmonitor"
  spec.version       = Xmonitor::VERSION
  spec.authors       = ["xmisao"]
  spec.email         = ["mail@xmisao.com"]

  spec.summary       = %q{Prototype of server monitoring tool using AWS.}
  spec.description   = %q{xmonitor is prototype of server monitoring tool. Aiming at easy and low cost monitoring tool for hobby use or small site.}
  spec.homepage      = "https://github.com/xmisao/xmonitor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency "aws-sdk-firehose", "~> 1.1"
  spec.add_runtime_dependency "aws-sdk-athena", "~> 1.0"
  spec.add_runtime_dependency "aws-sdk-s3", "~> 1.8"
  spec.add_runtime_dependency "posixpsutil", "~> 0.1"
end

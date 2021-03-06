# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud_front_interative_invalidator/version'

Gem::Specification.new do |spec|
  spec.name          = "cloud_front_interative_invalidator"
  spec.version       = CloudFrontInterativeInvalidator::VERSION
  spec.authors       = ["Ming Liu"]
  spec.email         = ["liuming@Lmws.net"]
  spec.summary       = %q{Create and show CloudFront invalidations in interactive command}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/liuming/cloud_front_interative_invalidator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk"
  spec.add_dependency "table_print"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end

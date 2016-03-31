# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbvmomi_helper/version'

Gem::Specification.new do |spec|
  spec.name          = 'rbvmomi_helper'
  spec.version       = RbVmomiHelper::VERSION
  spec.authors       = ['Deric Crago']
  spec.email         = ['deric.crago@gmail.com']

  spec.summary = 'A set of helper methods for RbVmomi.'
  spec.homepage = 'https://github.com/dericcrago/rbvmomi_helper'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency('bundler', '~> 1.11')
  spec.add_development_dependency('rake', '~> 10.0')
  spec.add_development_dependency('rspec', '~> 3.0')

  # Added
  spec.add_dependency('rbvmomi')
  spec.add_development_dependency('vcr')
  spec.add_development_dependency('webmock')
  spec.add_development_dependency('rubocop', '~> 0.37')
  spec.add_development_dependency('rubocop-checkstyle_formatter')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('simplecov-json')
  spec.add_development_dependency('simplecov-rcov')
end

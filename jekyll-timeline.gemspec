# frozen_string_literal: true

require_relative 'lib/jekyll-timeline/version'

Gem::Specification.new do |spec|
  spec.name             = 'jekyll-timeline'
  spec.version          = Jekyll::Timeline::VERSION
  spec.authors          = ['Paul Roub']
  spec.email            = ['paul@roub.net']
  spec.summary          = 'A Jekyll plugin to generate a timeline from a Google Sheet'
  spec.homepage         = 'https://github.com/paulroub/jekyll-plugin-timeline'
  spec.license          = 'MIT'

  spec.files            = Dir['lib/**/*']
  spec.extra_rdoc_files = Dir['README.md']
  spec.require_paths    = ['lib']

  spec.required_ruby_version = '>= 3.2.2'

  spec.add_dependency 'faraday', '~> 2.11.0'
  spec.add_dependency 'faraday-cookie_jar', '~> 0.0.7'
  spec.add_dependency 'faraday-follow_redirects', '~> 0.3.0'
  spec.add_dependency 'jekyll', '>= 4.3.2', '< 5.0'
  spec.add_dependency 'nokogiri', '~> 1.16.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop-jekyll', '~> 0.12.0'
  spec.add_development_dependency 'typhoeus', '>= 0.7', '< 2.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end

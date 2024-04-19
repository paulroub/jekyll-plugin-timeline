# frozen_string_literal: true

require 'jekyll'
require 'typhoeus' unless Gem.win_platform?
require 'nokogiri'
require 'csv'
require File.expand_path('../lib/jekyll-timeline', __dir__)

Jekyll.logger.log_level = :error

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  def source_dir(*files)
    File.join(File.expand_path('fixtures', __dir__), *files)
  end

  def dest_dir(*files)
    File.join(File.expand_path('dest',     __dir__), *files)
  end

  def make_context(registers = {})
    Liquid::Context.new({}, {}, { site: }.merge(registers))
  end
end

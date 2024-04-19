# frozen_string_literal: true

require 'nokogiri'
require 'csv'
require_relative './jekyll-timeline/parser'
require_relative './jekyll-timeline/formatter'

module TimelinePlugin
  # Generate a timeline page's content
  class TimelinePageGenerator < Jekyll::Generator
    safe true

    def generate(site)
      site.pages << TimelinePage.new(site)
    end
  end

  # Subclass of `Jekyll::Page` with custom method definitions.
  class TimelinePage < Jekyll::Page
    def initialize(site)
      @site = site             # the current site instance.
      @base = site.source      # path to the source directory.
      @dir  = 'timeline' # the directory the page will reside in.

      # All pages have the same filename, so define attributes straight away.
      @basename = 'index'      # filename without the extension.
      @ext      = '.html'      # the extension.
      @name     = 'index.html' # basically @basename + @ext.

      @data = {
        'page_title' => 'page timeline',
        'title' => full(@site.config['timeline']['title']) ? @site.config['timeline']['title'] : 'Timeline',
        'layout' => full(@site.config['timeline']['layout']) ? @site.config['timeline']['layout'] : 'default'
      }

      @csv_filename = Pathname.new(@site.config['timeline']['source'])

      self.content = page_content
    end

    # Placeholders that are used in constructing page URL.
    def url_placeholders
      {
        path: @dir,
        category: @dir,
        basename:,
        output_ext:
      }
    end

    def page_content
      data = CSV.table(@csv_filename)

      timeline = Jekyll::Timeline::Parser.new(data).parse

      doc = Nokogiri::HTML::DocumentFragment.parse "<dl class='jekyll-timeline'></dl>"

      build_timeline(doc.at_css('dl'), timeline)

      insert_css(doc)

      doc.to_html(encoding: 'UTF-8')
    end

    def build_timeline(wrapper, timeline)
      Nokogiri::HTML::Builder.with(wrapper) do |container|
        timeline.each do |event|
          id = Jekyll::Timeline::Formatter.format_id(event)

          container.dt(id:, class: 'jekyll-timeline-event') do
            container.span(event['date'].strftime('%B %d, %Y'), class: 'jekyll-timeline-date')

            container.span(event['summary'], class: 'jekyll-timeline-summary') do
              container.a('#', href: "##{id}", class: 'jekyll-timeline-permalink')
            end
          end

          next unless full(event['extras'])

          container.dd(class: 'jekyll-timeline-details') do |dd|
            event['extras'].each do |extra|
              dd.div do |div|
                Jekyll::Timeline::Formatter.format_extra(div, extra)
              end
            end
          end
        end
      end
    end

    def insert_css(doc)
      css_path = File.join(File.dirname(__FILE__), 'css/jekyll-timeline.css')
      css_text = File.read(css_path)

      Nokogiri::HTML::Builder.with(doc) do |doc_builder|
        doc_builder.style(css_text)
      end
    end

    def full(thing)
      !thing.nil? && !thing.empty?
    end
  end
end

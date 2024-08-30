# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require 'faraday-cookie_jar'
require 'faraday/follow_redirects'

module Jekyll
  module Timeline
    # Parse CSV data into a sorted timeline of records like:
    #
    # {
    #   'date' => Date,
    #   'title' => String,
    #   'extras' => [String]
    # }
    class Parser
      def initialize(csv)
        @csv = csv
      end

      def parse
        timeline = []
        @csv.each do |row|
          timeline << {
            'date' => Date.strptime(row[0], '%m/%d/%Y'),
            'summary' => row[1],
            'extras' => collect_extras(row[2..])
          }
        end

        timeline.sort_by { |event| event['date'] }
      end

      def collect_extras(items)
        items.compact.map { |item| pull_details(item) }.compact
      end

      def pull_details(item)
        text = item

        link = nil
        title = nil
        description = nil
        image = nil

        if item.start_with?('http')
          link = item

          begin
            body = get_page(link)
          rescue Faraday::FollowRedirects::RedirectLimitReached
            Jekyll.logger.warn "redirect limit reached for #{link}"
            return nil
          end

          doc = Nokogiri::HTML(body)

          title = get_text_at_xpath(doc, '//head//title')
          description = get_description(doc)
          image = get_content_at_xpath(doc, '//head//meta[@property="og:image"]')
        end

        { 'text' => text, 'link' => link, 'title' => title, 'description' => description, 'image' => image }
      end

      def get_page(link)
        Jekyll.logger.info "retrieving #{link}"
        options = {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
          },
          url: link
        }
        conn = Faraday.new(options) do |faraday|
          faraday.response :follow_redirects
          faraday.use :cookie_jar
          faraday.adapter Faraday.default_adapter
        end

        response = conn.get

        response.body
      end

      def get_description(doc)
        description = get_content_at_xpath(doc, '//head//meta[@name="description"]')

        if description.nil? || description.empty?
          description = get_content_at_xpath(doc, '//head//meta[@property="og:description"]')
        end

        description
      end

      def get_text_at_xpath(doc, xpath)
        nodes = doc.xpath(xpath)

        nodes.first.text if nodes.any?
      end

      def get_content_at_xpath(doc, xpath)
        nodes = doc.xpath(xpath)

        nodes.first['content'] if nodes.any?
      end
    end
  end
end

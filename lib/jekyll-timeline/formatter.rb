# frozen_string_literal: true

module Jekyll
  module Timeline
    # helper methods to format timeline components
    # for html use
    class Formatter
      def self.format_extra(container, extra)
        if full(extra['link'])
          format_link(container, extra)
        elsif full(extra['text'])
          container.p extra['text']
        end
      end

      def self.format_link(container, extra)
        title = full(extra['title']) ? extra['title'] : extra['link']

        if full(extra['image'])
          container.div(class: 'jekyll-timeline-image-box') do |div|
            div.a(href: extra['link']) do
              div.img src: extra['image'], class: 'jekyll-timeline-image'
            end
          end
        end

        container.div do |div|
          div.h3(class: 'jekyll-timeline-link') do
            div.a title, href: extra['link']
          end

          div.p extra['description'], class: 'jekyll-timeline-description' if full(extra['description'])
        end
      end

      def self.format_id(entry)
        # formate entry date as YYYY-MM-DD
        date_str = entry['date'].strftime('%Y-%m-%d')

        # replace non-alphanumeric characters with hyphens, and limit to 19 chars
        slug = entry['summary'].strip.downcase.gsub(/[^a-z0-9]/, '-').gsub(/-+/, '-').slice(0, 20)

        "#{date_str}-#{slug}"
      end

      def self.full(thing)
        !thing.nil? && !thing.empty?
      end
    end
  end
end

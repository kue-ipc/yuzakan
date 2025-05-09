# frozen_string_literal: true

# Yuzakan::Utils::Pager

module Yuzakan
  module Utils
    class Pager
      DEFAULT_PAGE = 1
      DEFAULT_PER_PAGE = 20
      MIN_PAGE = 1
      MAX_PAGE = 10000
      MIN_PER_PAGE = 10
      MAX_PER_PAGE = 100
      PAGE_RANGE = (MIN_PAGE..MAX_PAGE)
      PER_PAGE_RANGE = (MIN_PER_PAGE..MAX_PER_PAGE)

      attr_reader :page, :per_page

      def initialize(relation, page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE,
        create_link: nil, &block)
        @page = page.clamp(PAGE_RANGE)
        @per_page = per_page.clamp(PER_PAGE_RANGE)
        @create_link = create_link || block
        @relation = relation
      end

      def total
        @total ||= @relation.count
      end

      def offset
        @offset ||= (page - 1) * per_page
      end

      def first_page
        1
      end

      def last_page
        ((total - 1) / per_page) + 1
      end

      def prev_page
        return unless page > first_page

        page - 1
      end

      def next_page
        return unless page < last_page

        page + 1
      end

      def page_items
        @page_items ||=
          if @relation.is_a?(Array)
            @relation[offset, per_page] || []
          else
            # ROM Relation
            @relation.limit(per_page).offset(offset).to_a
          end
      end

      def all_items
        @all_items ||= @relation.to_a
      end

      def location
        @location ||= @create_link.call({page: page, per_page: per_page})
      end

      def headers
        {
          "Link" => header_link,
          "Content-Range" => header_content_range,
          "Content-Location" => location,
        }.compact
      end

      private def header_total_count
        total.to_s
      end

      private def header_link
        return if total.zero?
        return unless @create_link

        {
          first: first_page,
          prve: prev_page,
          next: next_page,
          last: last_page,
        }.compact.map { |key, value|
          link_item(@create_link.call({page: value, per_page: per_page}),
            rel: key.to_s)
        }.join(", ")
      end

      private def header_content_range
        return "items 0-0/0" if total.zero?

        "items #{offset}-#{offset + page_items.size - 1}/#{total}"
      end

      private def link_item(uri, **params)
        list = ["<#{uri}>"]
        list += params.map { |key, value| "#{key}=\"#{value}\"" }
        list.join("; ")
      end
    end
  end
end

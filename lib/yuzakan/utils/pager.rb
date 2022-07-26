# Yuzakan::Utils::Pager

module Yuzakan
  module Utils
    class Pager
      @@deafult_per_page = 20 # rubocop:disable Style/ClassVars

      attr_reader :total_count, :page_items

      def initialize(routes, name, params, all_items)
        @routes = routes
        @name = name
        @params = params.to_h
        @all_items = all_items

        @page = params[:page] || 1
        @per_page = params[:per_page] || @@deafult_per_page

        @item_offset = (@page - 1) * @per_page
        @page_items =  @all_items[@item_offset, @per_page] || []
      end

      def headers
        {
          'Total-Count' => header_total_count,
          'Link' => header_link,
          'Content-Range' => header_content_range,
        }
      end

      def header_total_count
        @all_items.size.to_s
      end

      def header_link
        return nil if @all_items.empty?

        first_page = 1
        last_page = ((@all_items.size - 1) / @per_page) + 1
        info_list = []
        info_list << {rel: 'first', page: first_page}
        info_list <<   {rel: 'prve', page: @page - 1} if @page != first_page
        info_list <<   {rel: 'next', page: @page + 1} if @page != last_page
        info_list <<   {rel: 'last', page: last_page}
        info_list.map do |info|
          link_item(@routes.url(@name, **@params, page: info[:page], per_page: @per_page), rel: info[:rel])
        end.join(', ')
      end

      def header_content_range
        return 'items 0-0/0' if @all_items.empty?

        "items #{@item_offset}-#{@item_offset + @page_items.size - 1}/#{@all_items.size}"
      end

      def link_item(uri, **params)
        list = ["<#{uri}>"]
        list += params.map { |key, value| "#{key}=\"#{value}\"" }
        list.join('; ')
      end
    end
  end
end

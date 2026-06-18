# frozen_string_literal: true

module API
  class IndexAction < API::Action
    MAX_PER_PAGE = 1000

    ORDER_PATTERNS = ["name", "label"].flat_map { |name| [name, "#{name}.asc", "#{name}.desc"] }.freeze

    MATCH_PATTERNS = [
      "extract",
      "partial",
      "forward",
      "backward",
    ].freeze

    params do
      optional(:page).value(:integer, gteq?: 1)
      optional(:per_page).value(:integer, gteq?: 1, lteq?: MAX_PER_PAGE)
      optional(:order).filled(:str?, included_in?: ORDER_PATTERNS)
      optional(:search).maybe(:str?, max_size?: 255)
      optional(:match).filled(:str?, included_in?: MATCH_PATTERNS)
    end

    private def index_params_from_request(request)
      params = request.params.to_h.slice(:page, :per_page)
      params[:order] = order_from_params(request.params)
      params[:query] = query_from_params(request.params)
      params[:filter] = filter_from_params(request.params)
      params
    end

    private def order_from_params(params)
      return nil unless params[:order]

      name, asc_desc = params[:order].split(".", 2).map(&:intern)
      {name => asc_desc || :asc}
    end

    private def query_from_params(params)
      return nil if params[:search].nil? || params[:search].empty?

      search = params[:search].gsub("*", "%").gsub("?", "_")
      case params[:match]
      when "extract"
        search
      when "forward"
        "#{search}%"
      when "backward"
        "%#{search}"
      when nil | "partial"
        "%#{search}%"
      end
    end

    private def filter_from_params(_params) = nil
  end
end

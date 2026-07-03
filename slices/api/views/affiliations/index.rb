# frozen_string_literal: true

module API
  module Views
    module Affiliations
      class Index < API::View
        decorate :affiliations
      end
    end
  end
end

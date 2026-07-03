# frozen_string_literal: true

module API
  module Views
    module Affiliations
      class Show < API::View
        decorate :affiliation
      end
    end
  end
end

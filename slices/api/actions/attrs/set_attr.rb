# frozen_string_literal: true

module API
  module Actions
    module Attrs
      module SetAttr
        def self.included(action)
          action.class_eval do
            params IdParams
            before :set_attr
          end
        end

        def initialize(attr_repository: AttrRepository.new, **opts)
          super
          @attr_repository ||= attr_repository
        end

        private def set_attr
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          @attr = @attr_repository.find_with_mappings_by_name(params[:id])

          halt_json 404 if @attr.nil?
        end
      end
    end
  end
end

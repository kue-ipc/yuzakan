# frozen_string_literal: true

module API
  module Actions
    module Attrs
      module Params
        class Create < Yuzakan::Action::Params
          params do
            required(:name).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            required(:type).filled(:str?, included_in?: Attr::TYPES)
            optional(:order).filled(:int?)
            optional(:hidden).filled(:bool?)
            optional(:readonly).filled(:bool?)
            optional(:code).maybe(:str?, max_size?: 4096)
            optional(:description).maybe(:str?, max_size?: 4096)
            optional(:attr_mappings).array(:hash) do
              required(:provider).filled(:str?, :name?, max_size?: 255)
              required(:key).filled(:str?, max_size?: 255)
              optional(:conversion).maybe(included_in?: AttrMapping::CONVERSIONS)
            end
          end
        end
      end
    end
  end
end

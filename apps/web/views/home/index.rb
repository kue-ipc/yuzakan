# frozen_string_literal: true

module Web
  module Views
    module Home
      class Index
        include Web::View
        layout false

        def title
          'ユーザー管理システム'
        end
      end
    end
  end
end

require 'json'

module Admin
  module Views
    module Providers
      class New
        include Admin::View

        def form
          adapters = Yuzakan::Adapters.list
            .each_with_index
            .filter { |adapter, _| adapter.usable? }
            .map { |adapter, idx| {id: idx, name: adapter.name} }

          form_for :provider, routes.providers_path do
            div class: 'form-group' do
              label 'プロバイダー名', for: :name
              text_field :name, class: 'form-control'
            end
            div id: 'provider-adapter',
                'data-adapters': "#{ha(JSON.generate(adapters))}"
            submit '作成', class: 'btn btn-primary'
          end
        end
      end
    end
  end
end

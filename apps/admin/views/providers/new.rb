require 'json'

module Admin
  module Views
    module Providers
      class New
        include Admin::View

        def form
          adapters = Yuzakan::Adapters.list
            .each_with_index
            .map { |adapter, idx| {id: idx, name: adapter.name} }



          form_for :provider, routes.providers_path do
            div class: 'form-group' do
              label 'プロバイダー名', for: :name
              text_field :name, class: 'form-control'
            end
            div id: 'provider-paramater',
                'data-adapters': "#{ha(adapters.to_json)}"
            # div class: 'form-group' do
            #   label 'アダプター', for: :adapter
            #   select :adapter, adapters, id: 'provider-adapter-select',
            #                              class: 'form-control'
            # end
            # div id: 'provider-paramaters'
            submit '作成'
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Views
    module AttrTypes
      class Index
        include Admin::View

        def form_attr_type(attr_type, providers)
          if attr_type
            mappings = providers.map do |provider|
              ifnone = -> { ProviderAttrMapping.new(provider_id: provider.id) }
              attr_type.provider_attr_mappings.find(ifnone) do |mapping|
                mapping.provider_id == provider.id
              end
            end
            form = Form.new(
              :attr_type,
              routes.path(:attr_type, id: attr_type.id),
              {attr_type: AttrType.new(
                name: attr_type.name,
                display_name: attr_type.display_name,
                type: attr_type.type,
                provider_attr_mappings: mappings)},
              method: :patch)
          else
            mappings = providers.map do |provider|
              ProviderAttrMapping.new(provider_id: provider.id)
            end
            form = Form.new(:attr_type, routes.path(:attr_types),
                            {attr_type: AttrType.new(
                              provider_attr_mappings: mappings)})
          end

          html.tr do
            div do
              form_for form do
                td class: 'table-primary' do
                  text_field :name, class: 'form-control mb-1'
                  text_field :display_name, class: 'form-control'
                end

                td class: 'table-primary' do
                  select :type, {
                    '真偽値' => 'boolean',
                    '文字列' => 'string',
                    '整数値' => 'integer',
                    '小数点数値' => 'float',
                    '日付' => 'date',
                    '時間' => 'time',
                    '日時' => 'datetime',
                  }, class: 'form-control'
                end

                td do
                  if attr_type
                    div class: 'mb-1' do
                      submit '更新', class: 'btn btn-warning'
                    end
                    div do
                      button class: 'btn btn-danger', type: 'button',
                             'data-toggle': 'modal',
                             'data-target': "\#attr-type-delete#{attr_type.id}" do
                        '削除'
                      end
                    end
                  else
                    submit '作成', class: 'btn btn-primary'
                  end
                end

                fields_for_collection :provider_attr_mappings do
                  td do
                    hidden_field :provider_id
                    text_field :name, class: 'form-control mb-1'
                    select :conversion, {
                      '変換なし' => '',
                      'POSIX時間' => 'posix_time',
                      'POSIX日付' => 'posix_date',
                      'PATH(パス)' => 'path'
                    }, class: 'form-control mb-1'
                  end
                end
              end
            end
            div(delete_modal(attr_type)) if attr_type
          end
        end

        private def delete_modal(attr_type)
          id = "attr-type-delete#{attr_type.id}"
          html.div id: id, class: 'modal fade',
                   tabindex: '-1', role: 'dialog',
                   'aria-labelledby': "#{id}-label", 'aria-hidden': true do
            div class: 'modal-dialog', role: 'document' do
              div class: 'modal-content' do
                div class: 'modal-header' do
                  h5 '属性の削除確認', id: "#{id}-label", class: 'modal-title'
                  button class: 'close', type: 'button',
                         'data-dismiss': 'modal', 'aria-label': 'Close' do
                    span 'aria-hidden': 'true' do
                      raw '&times;'
                    end
                  end
                end
                div class: 'modal-body' do
                  "属性「#{attr_type.name}」を削除してもよろしいですか？"
                end
                div class: 'modal-footer' do
                  button class: 'btn btn-secondary', type: 'button',
                         'data-dismiss': 'modal' do
                    '閉じる'
                  end
                  div do
                    form_for attr_type, routes.path(:attr_type, attr_type.id), method: :delete do
                      submit '削除', class: 'btn btn-danger'
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

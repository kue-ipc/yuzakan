module Admin
  module Views
    module Attrs
      class Index
        include Admin::View

        def form_attr(attr, providers)
          if attr
            mappings = providers.map do |provider|
              ifnone = -> { AttrMapping.new(provider_id: provider.id) }
              attr.attr_mappings.find(ifnone) do |mapping|
                mapping.provider_id == provider.id
              end
            end
            form = Form.new(
              :attr,
              routes.path(:attr, id: attr.id),
              {attr: Attr.new(
                name: attr.name,
                display_name: attr.display_name,
                type: attr.type,
                attr_mappings: mappings)},
              method: :patch)
          else
            mappings = providers.map do |provider|
              AttrMapping.new(provider_id: provider.id)
            end
            form = Form.new(:attr, routes.path(:attrs),
                            {attr: Attr.new(
                              attr_mappings: mappings)})
          end

          html.tr do
            div do
              form_for form do
                td do
                  text attr&.order
                end

                td class: 'table-primary' do
                  text_field :name, class: 'form-control mb-1', required: true
                  text_field :display_name, class: 'form-control',
                                            required: true
                end

                td class: 'table-primary' do
                  select :type, {
                    '文字列' => 'string',
                    '真偽値' => 'boolean',
                    '整数値' => 'integer',
                    '小数点数値' => 'float',
                    '日付' => 'date',
                    '時間' => 'time',
                    '日時' => 'datetime',
                  }, class: 'form-control'
                end

                td do
                  if attr
                    div class: 'mb-1' do
                      submit '更新', class: 'btn btn-warning'
                    end
                    div do
                      button class: 'btn btn-danger', type: 'button',
                             'data-toggle': 'modal',
                             'data-target': "\#attr-type-delete#{attr.id}" do
                        '削除'
                      end
                    end
                  else
                    submit '作成', class: 'btn btn-primary'
                  end
                end

                fields_for_collection :attr_mappings do
                  td do
                    hidden_field :provider_id
                    text_field :name, class: 'form-control mb-1'
                    select :conversion, {
                      '変換なし' => '',
                      'POSIX時間' => 'posix_time',
                      'POSIX日付' => 'posix_date',
                      'PATH(パス)' => 'path',
                      '英日' => 'e2j',
                      '日英' => 'j2e',
                    }, class: 'form-control mb-1'
                  end
                end
              end
            end
            div(delete_modal(attr)) if attr
          end
        end

        private def delete_modal(attr)
          id = "attr-type-delete#{attr.id}"
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
                  "属性「#{attr.name}」を削除してもよろしいですか？"
                end
                div class: 'modal-footer' do
                  button class: 'btn btn-secondary', type: 'button',
                         'data-dismiss': 'modal' do
                    '閉じる'
                  end
                  div do
                    form_for attr, routes.path(:attr, attr.id),
                             method: :delete do
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

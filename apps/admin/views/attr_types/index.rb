module Admin
  module Views
    module AttrTypes
      class Index
        include Admin::View

        def form_attr_type(attr_type, providers)
          if attr_type
            form = Form.new(
              :attr_type,
              routes.path(:attr_type, id: attr_type.id),
              {attr_type: attr_type},
              method: :patch)
            mapping_map = attr_type.provider_attr_mappings.map do |mapping|
              [mapping.provider_id, mapping]
            end.to_h
          else
            form = Form.new(:attr_type, routes.path(:attr_types))
            mapping_map = {}
          end

          html.tr do
            div do
              form_for form do
                td class: 'table-primary' do
                  text_field :name, class: 'form-control mb-1'
                  text_field :display_name, class: 'form-control'
                end

                td class: 'table-primary'  do
                  select :type, {
                    '文字列' => 'string',
                    '整数値' => 'integer',
                    '小数点数値' => 'float',
                    '日付' => 'date',
                    '時間' => 'time',
                    '日時' => 'datetime',
                    '真偽値' => 'boolean',
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

                fields_for :provider_attr_mappings do
                  providers.each do |provider|
                    td do
                      fields_for provider.name, mapping_map[provider.id] do |ff|
                        pp mapping_map[provider.id]
                        hidden_field :provider_id
                        text_field :name, class: 'form-control mb-1'
                        select :conversion, {
                          '変換なし' => '',
                          'POSIX時間' => 'posix_time',
                          'POSIX日付' => 'posix_date',
                        }, class: 'form-control mb-1'
                      end
                    end
                  end
                end
              end
            end
            if attr_type
              div(delete_modal(attr_type))
            end
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

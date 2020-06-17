module Admin
  module Views
    module AttrTypes
      class Index
        include Admin::View

        def form_attr_type(attr_type, providers)
          if attr_type
            form = Form.new(:attr_type,
              routes.path(:attr_type, id: attry_type.id))
            mapping_map = provider_attr_mappings.map do |mapping|
              [mapping.provider_id, mapping]
            end.to_h
            submit_label = '更新'
          else
            form = Form.new(:attr_type, routes.path(:attr_types))
            mapping_map = {}
            submit_label = '作成'
          end

          form_for form do
            tr do
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
                submit submit_label, class: 'btn btn-primary'
              end

              fields_for :provider_attr_mapping do
                providers.each do |provider|
                  td do
                    fields_for provider.name, mapping_map[provider.id] do
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
        end
      end
    end
  end
end

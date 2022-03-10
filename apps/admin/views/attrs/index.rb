module Admin
  module Views
    module Attrs
      class Index
        include Admin::View

        private def delete_modal(attr)
          id = "attr-type-delete#{attr.id}"
          html.div id: id, class: 'modal fade',
                   tabindex: '-1',
                   'aria-labelledby': "#{id}-label", 'aria-hidden': true do
            div class: 'modal-dialog', role: 'document' do
              div class: 'modal-content' do
                div class: 'modal-header' do
                  h5 '属性の削除確認', id: "#{id}-label", class: 'modal-title'
                  button class: 'btn-close', type: 'button',
                         'data-bs-dismiss': 'modal', 'aria-label': '閉じる'
                end
                div class: 'modal-body' do
                  "属性「#{attr.name}」を削除してもよろしいですか？"
                end
                div class: 'modal-footer' do
                  button class: 'btn btn-secondary', type: 'button',
                         'data-bs-dismiss': 'modal' do
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

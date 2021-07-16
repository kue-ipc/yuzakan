module Yuzakan
  module Helpers
    module Modal
      private def modal(id, title: nil, form: nil,
                        submit_name: '送信', submit_level: 'primary',
                        &block)
        label_id = "#{id}-label"
        title ||= id

        modal_classes = ['modal', 'fade']
        dialog_classes = ['modal-dialog', 'modal-dialog-centered',
                          'modal-dialog-scrollable', 'modal-lg',]
        form_classes = []
        form_classes << 'submit-before-agreement' if agreement

        submit_classes = ['btn']

        html.div id: id, class: modal_classes,
                 tabindex: '-1', role: 'dialog',
                 'aria-labelledby': label_id, 'aria-hidden': true do
          div class: dialog_classes, role: 'document' do
            div class: 'modal-content' do
              div class: 'modal-header' do
                h5 title, id: label_id, class: 'modal-title'
                button class: 'close', type: 'button',
                       'data-dismiss': 'modal', 'aria-label': '閉じる' do
                  span raw('&times;'), 'aria-hidden': 'true'
                end
              end
              div class: 'modal-body' &block
              div class: 'modal-footer' do
                if form
                  form_for form, class: form_classes do
                    

                    submit submit_name, class: 'btn btn-danger'
                  end
                button '閉じる', class: 'btn btn-secondary', type: 'button',
                                 'data-dismiss': 'modal'
                end
              end
            end
          end
        end
      end
    end
  end
end

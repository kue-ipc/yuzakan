module Yuzakan
  module Helpers
    module Modal
      def modal(id, form, title: nil, modal_dialog: {}, submit_button: {},
                content: nil)
        title ||= id
        label_id = "#{id}-label"

        submit_button = {label: '送信', color: 'primary', disabled: false}
          .merge(submit_button)
        modal_dialog = {size: :middel, centered: true}.merge(modal_dialog)

        modal_classes = ['modal', 'fade']

        dialog_classes = ['modal-dialog', 'modal-dialog-centered',
                          'modal-dialog-scrollable',]
        dialog_classes << 'modal-dialog-centered' if modal_dialog[:centered]
        case modal_dialog[:size]
        when :small
          dialog_classes << 'modal-sm'
        when :middle
          # do nothing
        when :large
          dialog_classes << 'modal-lg'
        end

        form_classes = []

        submit_classes = ['btn', "btn-#{submit_button[:color]}", 'submit']

        html.div id: id, class: modal_classes, role: 'dialog', tabindex: '-1',
                 'aria-labelledby': label_id, 'aria-hidden': 'true' do
          div class: dialog_classes do
            form_for form, class: form_classes do
              div class: 'modal-content' do
                div class: 'modal-header' do
                  h5 title, id: label_id, class: 'modal-title'
                  button type: 'button', class: 'btn-close',
                         'data-bs-dismiss': 'modal', 'aria-label': '閉じる'
                end
                div class: 'modal-body' do
                  if block_given?
                    yield
                  else
                    p content
                  end
                end
                div class: 'modal-footer' do
                  submit submit_button[:label],
                         class: submit_classes,
                         disabled: submit_button[:disabled]
                  button '閉じる', class: 'btn btn-secondary', type: 'button',
                                'data-bs-dismiss': 'modal'
                end
              end
            end
          end
        end
      end
    end
  end
end

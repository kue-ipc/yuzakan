# frozen_string_literal: true

module Web
  module Views
    module Gsuite
      class Show
        include Web::View

        def menu_items
          items = []
          # if gsuite_user
            # if gsuite_user[:locked]
              items << {
                name: 'ロック解除',
                url: '#gsuite-unlock-user',
                description: 'Google アカウントのロックを解除します。同時にパスワードもリセットされます。',
                color: 'warning',
                type: :modal,
              }
            # else
              items << {
                name: 'パスワードリセット',
                url: '#gsuite-reset-user',
                description: 'Google アカウントのパスワードをリセットします。同時に二段階認証設定もリセットします。',
                color: 'warning',
                type: :modal,
              }
            # end
            items << {
              name: 'アカウント削除',
              url: '#gsuite-destroy-user',
              description: 'Google アカウントを削除します。',
              color: 'danger',
              type: :modal,
            }
          # else
            items << {
              name: 'アカウント作成',
              url: '#gsuite-create-user',
              description: 'Googleアカウントを作成します。',
              color: 'primary',
              type: :modal,
            }
          # end
          items
        end

        def modal(id, form, title: nil, content: nil, rules: nil,
                            submit_button: { label: '送信', color: 'primary', },
                            agreement: false)
          label_id = "#{id}-label"

          modal_classes = ['modal', 'fade']
          dialog_classes = ['modal-dialog', 'modal-dialog-centered',
                            'modal-dialog-scrollable', 'modal-lg']
          form_classes = []
          form_classes << 'submit-before-agreement' if agreement

          title ||= id

          html.div id: id, class: modal_classes, role: 'dialog', tabindex: '-1',
                   'aria-labelledby': label_id, 'aria-hidden':  'true' do
            div class: dialog_classes do
              form_for form, class: form_classes do
                div class: 'modal-content' do
                  div class: 'modal-header' do
                    h5 id: 'gsuite-create-user-label', class: 'modal-title' do
                      text title
                    end
                    button type: 'button', class: 'close',
                           'data-dismiss': 'modal', 'aria-label': '閉じる' do
                      span raw('&times;'), 'aria-hidden': 'true'
                    end
                  end
                  div class: 'modal-body' do
                    p content if content
                    if rules
                      hr
                      if agreement
                        p '処理を実行する前に、下記すべてを必ず確認し、その内容について同意してください。'
                      else
                        p '処理を実行する前に、下記すべてを必ず確認してください。'
                      end
                      ul do
                        rules.each do |rule|
                          li rule
                        end
                      end
                    end
                    if agreement
                      hr
                      div class: 'form-check' do
                        check_box :agreement,
                                  class: 'form-check-input agreement'
                        label class: 'form-check-label', for: :agreement do
                          text '私は、上記すべてについて同意します。'
                        end
                      end
                    end
                  end
                  div class: 'modal-footer' do
                    submit submit_button[:label],
                           class: "btn btn-#{submit_button[:color]} submit",
                           disabled: agreement
                    button class: 'btn btn-secondary', type: 'button',
                           'data-dismiss': 'modal' do
                      text '閉じる'
                    end
                  end
                end
              end
            end
          end
        end

        def gsuite_create_user_form
          Form.new(:gsuite_create, routes.path(:gsuite))
        end

        def gsuite_destroy_user_form
          Form.new(:gsuite_destroy, routes.path(:gsuite), {}, method: :delete)
        end

        def gsuite_reset_user_form
          Form.new(:gsuite_reset, routes.path(:reset_gsuite))
        end

        def gsuite_unlock_user_form
          Form.new(:gsuite_unlock, routes.path(:unlock_gsuite))
        end

        def gsuite_create_user_rules
          [
            '作成されるGoogleアカウントは大学メールアドレスになります。',
            'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
            '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
            '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
            'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
            'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
          ]
        end

        def gsuite_destroy_user_rules
          [
            '作成されるGoogleアカウントは大学メールアドレスになります。',
            'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
            '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
            '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
            'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
            'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
          ]
        end

        def gsuite_reset_user_rules
          [
            'パスワードリセットを行うと、Google アカウントを使用したアプリケーションで再ログインが必要になる場合があります。',
            '2段階認証を設定している場合は、2段階認証も解除されます。',
            '1日あたりのパスワードリセットを行える回数には限りがあります。',
          ]
        end

        def gsuite_unlock_user_rules
          [
            '作成されるGoogleアカウントは大学メールアドレスになります。',
            'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
            '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
            '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
            'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
            'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
          ]
        end
      end
    end
  end
end

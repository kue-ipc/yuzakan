# frozen_string_literal: true

module Web
  module Views
    module Gsuite
      class Show
        include Web::View

        def available_operations
          return [:gsuite_create, :gsuite_destroy, :gsuite_password_create, :gsuite_lock_destroy]
          @available_operations ||= [].tap do |operations|
            if gsuite_user
              if gsuite_user[:locked]
                operations << :gsuite_lock_destroy
              else
                operations << :gsuite_password_create
              end
              operations << :gsuite_destroy
            else
              operations << :gsuite_create
            end
          end
        end

        def menu_operations
          @menu_operations ||= {
            gsuite_create: {
              name: 'アカウント作成',
              description: 'Googleアカウントを作成します。',
              color: 'primary',
              type: :modal,
            },
            gsuite_destroy: {
              name: 'アカウント削除',
              description: 'Google アカウントを削除します。',
              color: 'danger',
              type: :modal,
            },
            gsuite_password_create: {
              name: 'パスワードリセット',
              description: 'Google アカウントのパスワードをリセットします。同時に二段階認証設定もリセットします。',
              color: 'warning',
              type: :modal,
            },
            gsuite_lock_destroy: {
              name: 'ロック解除',
              description: 'Google アカウントのロックを解除します。同時にパスワードもリセットされます。',
              color: 'warning',
              type: :modal,
            },
          }
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

        def modal_forms
          @modal_forms ||= {
            gsuite_create: Form.new(:gsuite_create, routes.path(:gsuite)),
            gsuite_destroy: Form.new(:gsuite_destroy, routes.path(:gsuite), {},
                                     method: :delete),
            gsuite_password_create: Form.new(:gsuite_password_create,
                                             routes.path(:gsuite_password)),
            gsuite_unlock_user: Form.new(:gsuite_unlock_user,
                                         routes.path(:gsuite_lock), {},
                                         method: :delete),
          }
        end

        def modal_rules
          @modal_rules ||= {
            gsuite_create: [
              '作成されるGoogleアカウントは大学メールアドレスになります。',
              'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
              '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
              '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
              'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
              'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
            ],
            gsuite_destroy: [
              '作成されるGoogleアカウントは大学メールアドレスになります。',
              'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
              '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
              '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
              'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
              'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
            ],
            gsuite_password_create: [
              'パスワードリセットを行うと、Google アカウントを使用したアプリケーションで再ログインが必要になる場合があります。',
              '2段階認証を設定している場合は、2段階認証も解除されます。',
              '1日あたりのパスワードリセットを行える回数には限りがあります。',
            ],
            gsuite_lock_destroy: [
              '作成されるGoogleアカウントは大学メールアドレスになります。',
              'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
              '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
              '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
              'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
              'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
            ]
          }
        end

        def modal_options
          @modal_opitons ||= {
            gsuite_create: {
              title: 'Google アカウント 作成',
              content: 'ログインしているユーザーの Google アカウント を作成します。',
              submit_button: { label: 'アカウントを作成する', color: 'primary', },
              agreement: true,
            },
            gsuite_destroy: {
              title: 'Google アカウント 削除',
              content: 'ログインしているユーザーの Google アカウント を削除します。',
              submit_button: { label: 'アカウントを削除する', color: 'danger', },
            },
            gsuite_password_create: {
              title: 'Google アカウント パスワードリセット',
              content: 'ログインしているユーザーの Google アカウント のパスワードをリセットします。',
              submit_button: { label: 'パスワードをリセットする', color: 'warning', },
            },
            gsuite_lock_destroy: {
              title: 'Google アカウント ロック解除',
              content: 'ログインしているユーザーの Google アカウント のロックを解除します。',
              submit_button: { label: 'ロックを解除する', color: 'primary', },
            },
          }
        end
      end
    end
  end
end

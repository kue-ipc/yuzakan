module Web
  module Views
    module Google
      class Show
        include Web::View

        def available_operations
          @available_operations ||= [].tap do |operations|
            if google_user
              case google_user[:state]
              when :available
                operations << :google_password_create
                operations << :google_code_create if google_user[:mfa]
                # operations << :google_destroy
              when :locked
                operations << :google_lock_destroy
                # operations << :google_destroy
              end
              # :disabled and else is nothing
            else
              operations << :google_create
            end
          end
        end

        def menu_operations
          @menu_operations ||= {
            google_create: {
              name: 'アカウント作成',
              description: 'Googleアカウントを作成します。',
              color: 'primary',
              type: :modal,
            },
            google_destroy: {
              name: 'アカウント削除',
              description: 'Google アカウントを削除します。',
              color: 'danger',
              type: :modal,
            },
            google_password_create: {
              name: 'パスワードリセット',
              description: 'Google アカウントのパスワードをリセットします。',
              color: 'warning',
              type: :modal,
            },
            google_lock_destroy: {
              name: 'ロック解除',
              description: 'Google アカウントのロックを解除します。同時にパスワードをリセットすることができます。',
              color: 'warning',
              type: :modal,
            },
            google_code_create: {
              name: 'バックアップコード生成',
              description: 'Google アカウントの2段階認証プロセスのためのバックアップコードを生成します。',
              color: 'warning',
              type: :modal,
            },
          }
        end

        def modal(id, form, title: nil, content: nil, rules: nil,
                  submit_button: {label: '送信', color: 'primary'},
                  agreement: false, inputs: nil)
          label_id = "#{id}-label"

          modal_classes = ['modal', 'fade']
          dialog_classes = ['modal-dialog', 'modal-dialog-centered',
                            'modal-dialog-scrollable', 'modal-lg',]
          form_classes = []
          form_classes << 'submit-before-agreement' if agreement

          title ||= id

          html.div id: id, class: modal_classes, role: 'dialog', tabindex: '-1',
                   'aria-labelledby': label_id, 'aria-hidden':  'true' do
            div class: dialog_classes do
              form_for form, class: form_classes do
                div class: 'modal-content' do
                  div class: 'modal-header' do
                    h5 id: 'google-create-user-label', class: 'modal-title' do
                      text title
                    end
                    button type: 'button', class: 'btn-close',
                           'data-bs-dismiss': 'modal', 'aria-label': '閉じる'
                  end
                  div class: 'modal-body' do
                    p content if content
                    if rules
                      hr
                      if agreement
                        p '処理を実行する前に、下記全てを確認し、その内容について同意してください。'
                      else
                        p '処理を実行する前に、下記全てを確認してください。'
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
                                  class: 'form-check-input agreement',
                                  name: 'agreement'
                        label class: 'form-check-label', for: :agreement do
                          text '私は、上記全てについて同意します。'
                        end
                      end
                    end
                    if inputs && !inputs.empty?
                      hr
                      inputs.each do |input_data|
                        div class: 'form-check' do
                          check_box input_data[:name],
                                    class: 'form-check-input',
                                    checked: input_data[:default] && 'checked'
                          label class: 'form-check-label',
                                for: input_data[:name] do
                            text input_data[:text]
                          end
                        end
                      end
                    end
                  end
                  div class: 'modal-footer' do
                    submit submit_button[:label],
                           class: "btn btn-#{submit_button[:color]} submit",
                           disabled: agreement
                    button class: 'btn btn-secondary', type: 'button',
                           'data-bs-dismiss': 'modal' do
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
            google_create: Form.new(:google_create, routes.path(:google)),
            google_destroy: Form.new(:google_destroy, routes.path(:google), {},
                                     method: :delete),
            google_password_create: Form.new(:google_password_create,
                                             routes.path(:google_password)),
            google_lock_destroy: Form.new(:google_lock_destroy,
                                          routes.path(:google_lock), {},
                                          method: :delete),
            google_code_create: Form.new(:google_code_create,
                                         routes.path(:google_code)),
          }
        end

        def modal_rules
          @modal_rules ||= {
            google_create: [
              '作成されるGoogleアカウントは大学メールアドレスになります。',
              'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
              '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
              '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
              'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
              'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
              'アカウント名と初期パスワードは、処理実行後の画面に表示されます。',
            ],
            google_destroy: [
              'アカウントを削除すると、Google アカウントを使用する各サービスが利用できなくなります。',
              '削除から20日後までは復元が可能です。20日をすぎると、アカウントが所有者である全てのデータが削除されます。',
              '一部のデータは削除実施後即座に削除される場合があります。これらのデータについては、アカウントを復元しても元に戻りません。',
            ],
            google_password_create: [
              'パスワードリセットを行うと、Google アカウントを使用したアプリケーションで再ログインが必要になる場合があります。',
              '2段階認証は解除やリセットされません。2段階認証を設定している場合は、リセット後の再ログインで2要素目が求められる場合があります。',
              '1日あたりのパスワードリセットを行える回数には限りがあります。',
              '新しい初期パスワードは、処理実行後の画面に表示されます。',
            ],
            google_lock_destroy: [
              'ロック解除とともにパスワードリセットを行うことができます。新しい初期パスワードは、処理実行後の画面に表示されます。',
              '2段階認証は解除やリセットされません。2段階認証を設定している場合は、ロック解除後のログインで2要素目が求められる場合があります。',
              'パスワードリセットを行いたくない場合は、下記のチェックボックスを外してください。',
            ],
            google_code_create: [
              'バックアップコード生成を行うと、以前取得したバックアップコードは使用できなくなります。',
              'パスワードはリセットされません。パスワードも忘れた場合は、コード生成後にパスワードリセットを行ってください。',
              '1日あたりのバックアップコード生成を行える回数には限りがあります。',
              '生成したバックアップコードは、処理実行後の画面に表示されます。',
            ],
          }
        end

        def modal_options
          @modal_opitons ||= {
            google_create: {
              title: 'Google アカウント 作成',
              content: 'あなたの Google アカウント を作成します。',
              submit_button: {label: 'アカウントを作成する', color: 'primary'},
              agreement: true,
            },
            google_destroy: {
              title: 'Google アカウント 削除',
              content: 'あなたの Google アカウント を削除します。',
              submit_button: {label: 'アカウントを削除する', color: 'danger'},
            },
            google_password_create: {
              title: 'Google アカウント パスワードリセット',
              content: 'あなたの Google アカウント のパスワードをリセットします。',
              submit_button: {label: 'パスワードをリセットする', color: 'warning'},
            },
            google_lock_destroy: {
              title: 'Google アカウント ロック解除',
              content: 'あなたの Google アカウント のロックを解除します。',
              submit_button: {label: 'ロックを解除する', color: 'warning'},
              inputs: [
                {
                  name: :password_reset,
                  text: 'ロック解除とともにパスワードをリセットします。',
                  default: true,
                },
              ],
            },
            google_code_create: {
              title: 'Google アカウント バックアップコード生成',
              content: 'あなたの Google アカウント の2段階認証プロセスのための、バックアップコードを生成します。',
              submit_button: {label: 'バックアップコードを生成する', color: 'warning'},
            },
          }
        end
      end
    end
  end
end

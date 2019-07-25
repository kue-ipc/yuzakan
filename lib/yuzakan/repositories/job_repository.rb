# frozen_string_literal: true

# 文字列として処理する。
# aciton
# - authenticate
# - change_password
# - reset_password
# - create_user
# - delete_user
# - modify_user
# ...

# status
# - new
# - running
# - waiting
# - canceled
# - done
# - faulted

# result
# - success
# - failure
# - error

class JobRepository < Hanami::Repository
  associations do
    belongs_to :user
  end

  def job_create(owner: nil, client: nil, user: nil, action:, params: nil)
    create(owner_id: owner&.id, client: client&.to_s, user_id: user&.id,
           action: action, params: params, status: 'new')
  end

  def job_begin(id)
    update(id, status: 'running', begin_at: Time.now)
  end

  # 開始日時は設定しない
  def job_start(id)
    update(id, status: 'running')
  end

  def job_stop(id)
    update(id, status: 'waiting')
  end

  private def job_done(id, result)
    update(id, status: 'done', result: result, end_at: Time.now)
  end

  def job_succeeded(id)
    job_done(id, 'success')
  end

  def job_failed(id)
    job_done(id, 'failure')
  end

  def job_errored(id)
    job_done(id, 'error')
  end
end

# frozen_string_literal: true

RSpec.describe RegisterUser do
  init_intercactor_spec(self)
  let(:interactor) { described_class.new(**interactor_opts) }
  let(:interactor_opts) { {user_repository: user_repository} }
  let(:params) {
    {
      username: 'user',
      display_name: 'ユーザー',
      email: 'user@exapmle.jp',
      primary_group: 'group',
      groups: ['admin', 'staff'],
    }
  }

  it 'is successful' do
    result = interactor.call(params)
    expect(result.successful?).to eq true
    expect(result.user).to eq user_with_groups
  end
end

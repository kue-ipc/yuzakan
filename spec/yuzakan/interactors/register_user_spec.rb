# frozen_string_literal: true

RSpec.describe RegisterUser do
  init_intercactor_spec
  let(:interactor) { described_class.new(**interactor_opts) }
  let(:interactor_opts) { {user_repository: user_repository, member_repository: member_repository, group_repository: group_repository} }
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
    allow(user_repository).to receive(:transaction).and_yield
    allow(member_repository).to receive(:transaction).and_yield

    result = interactor.call(params)
    expect(result.successful?).to eq true
    expect(result.user).to eq user_with_groups
  end
end

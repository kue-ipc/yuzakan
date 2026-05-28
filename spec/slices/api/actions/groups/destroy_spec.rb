# frozen_string_literal: true

RSpec.describe API::Actions::Groups::Destroy do
  init_action_spec

  let(:action_opts) { {group_repo: group_repo} }

  let(:action_params) { {id: id} }

  let(:id) { "group42" }

  # TODO: パターン
end

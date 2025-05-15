# frozen_string_literal: true

RSpec.describe API::Actions::Config::Update do
  init_action_spec

  let(:action_params) { updated_config.to_h }
  let(:action_opts) {
    allow(config_repo).to receive(:set).and_return(updated_config)
    {
      config_repo: config_repo,
    }
  }
  let(:updated_config) { create_struct(:config, :another_config) }

  it "is failure" do
    response = action.call(params)
    expect(response).to be_client_error
    expect(response.status).to eq 403
  end

  context "when admin" do
    let(:user) { create_struct(:user, :superuser) }

    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq(
        title: updated_config.title,
        domain: updated_config.domain,
        session_timeout: updated_config.session_timeout,
        auth_failure_limit: updated_config.auth_failure_limit,
        auth_failure_duration: updated_config.auth_failure_duration,
        password_min_size: updated_config.password_min_size,
        password_max_size: updated_config.password_max_size,
        password_min_types: updated_config.password_min_types,
        password_min_score: updated_config.password_min_score,
        password_prohibited_chars: updated_config.password_prohibited_chars,
        password_extra_dict: updated_config.password_extra_dict.to_a,
        generate_password_size: updated_config.generate_password_size,
        generate_password_type: updated_config.generate_password_type,
        generate_password_chars: updated_config.generate_password_chars,
        contact_name: updated_config.contact_name,
        contact_email: updated_config.contact_email,
        contact_phone: updated_config.contact_phone,
        created_at: JSON.parse(updated_config.created_at.to_json),
        updated_at: JSON.parse(updated_config.updated_at.to_json))
    end
  end
end

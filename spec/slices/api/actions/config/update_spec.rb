# frozen_string_literal: true

RSpec.describe API::Actions::Config::Update do
  init_action_spec

  let(:action_params) { {title: "ほげ"} }
  let(:action_opts) {
    allow(config_repo).to receive(:put).and_return(config)
    {
      config_repo: config_repo,
    }
  }
  let(:updated_config) { create_struct(:config, :another_config)}

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
      expect(json[:data].except(:update_at)).to eq({
        title: config.title,
        domain: config.domain,
        session_timeout: config.session_timeout,
        auth_failure_limit: config.auth_failure_limit,
        auth_failure_duration: config.auth_failure_duration,
        password_min_size: config.password_min_size,
        password_max_size: config.password_max_size,
        password_min_types: config.password_min_types,
        password_min_score: config.password_min_score,
        password_prohibited_chars: config.password_prohibited_chars,
        password_extra_dict: config.password_extra_dict.to_a,
        generate_password_size: config.generate_password_size,
        generate_password_type: config.generate_password_type,
        generate_password_chars: config.generate_password_chars,
        contact_name: config.contact_name,
        contact_email: config.contact_email,
        contact_phone: config.contact_phone,
        created_at: JSON.parse(config.created_at.to_json),
      }.merge(action_params))
      expect(json[:data][:update_at]).not_to eq(JSON.parse(config.updated_at.to_json))
    end
  end
end

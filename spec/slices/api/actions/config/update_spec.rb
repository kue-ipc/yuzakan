# frozen_string_literal: true

RSpec.describe API::Actions::Config::Update do
  init_action_spec

  let(:action_params) { updated_config.to_h }
  let(:action_opts) {
    allow(config_repo).to receive(:set).and_return(updated_config)
    {config_repo: config_repo}
  }
  let(:updated_config) { create_struct(:config, :another_config) }

  it_behaves_like "forbidden"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "forbidden"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "forbidden"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "forbidden"
  end

  context "when superuser" do
    include_context "when superuser"

    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq(
        title: updated_config.title,
        description: updated_config.description,
        domain: updated_config.domain,
        sessionTimeout: updated_config.session_timeout,
        authFailureWaiting: updated_config.auth_failure_waiting,
        authFailureLimit: updated_config.auth_failure_limit,
        authFailureDuration: updated_config.auth_failure_duration,
        passwordMinSize: updated_config.password_min_size,
        passwordMaxSize: updated_config.password_max_size,
        passwordMinTypes: updated_config.password_min_types,
        passwordMinScore: updated_config.password_min_score,
        passwordProhibitedChars: updated_config.password_prohibited_chars,
        passwordExtraDict: updated_config.password_extra_dict.to_a,
        generatePasswordSize: updated_config.generate_password_size,
        generatePasswordType: updated_config.generate_password_type,
        generatePasswordChars: updated_config.generate_password_chars,
        contactName: updated_config.contact_name,
        contactEmail: updated_config.contact_email,
        contactPhone: updated_config.contact_phone,
        createdAt: JSON.parse(updated_config.created_at.to_json),
        updatedAt: JSON.parse(updated_config.updated_at.to_json))
    end
  end
end

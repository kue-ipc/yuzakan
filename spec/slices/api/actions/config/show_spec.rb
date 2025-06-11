# frozen_string_literal: true

RSpec.describe API::Actions::Config::Show do
  init_action_spec

  it "is successful" do
    response = action.call(params)
    expect(response).to be_successful
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:data]).to eq({
      title: config.title,
      description: config.description,
      domain: config.domain,
      sessionTimeout: config.session_timeout,
      authFailureWaiting: config.auth_failure_waiting,
      authFailureLimit: config.auth_failure_limit,
      authFailureDuration: config.auth_failure_duration,
      passwordMinSize: config.password_min_size,
      passwordMaxSize: config.password_max_size,
      passwordMinTypes: config.password_min_types,
      passwordMinScore: config.password_min_score,
      passwordProhibitedChars: config.password_prohibited_chars,
      passwordExtraDict: config.password_extra_dict.to_a,
      generatePasswordSize: config.generate_password_size,
      generatePasswordType: config.generate_password_type,
      generatePasswordChars: config.generate_password_chars,
      contactName: config.contact_name,
      contactEmail: config.contact_email,
      contactPhone: config.contact_phone,
      createdAt: JSON.parse(config.created_at.to_json),
      updatedAt: JSON.parse(config.updated_at.to_json),
    })
  end
end

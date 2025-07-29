# frozen_string_literal: true

RSpec.describe API::Views::Parts::Config do
  init_part_spec

  let(:value) { config }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      title: value.title,
      description: value.description,
      domain: value.domain,
      session_timeout: 3600, # default
      auth_failure_waiting: 2, # default
      auth_failure_limit: 5, # default
      auth_failure_duration: 600, # default
      password_min_size: 8, # default
      password_max_size: 64, # default
      password_min_types: 1, # default
      password_min_score: 0, # default
      password_prohibited_chars: "", # default
      password_extra_dict: [], # default
      generate_password_size: 24, # default
      generate_password_type: "ascii", # default
      generate_password_chars: " ", # default
      contact_name: value.contact_name,
      contact_email: value.contact_email,
      contact_phone: value.contact_phone,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      title: value.title,
      description: value.description,
      domain: value.domain,
      sessionTimeout: 3600, # default
      authFailureWaiting: 2, # default
      authFailureLimit: 5, # default
      authFailureDuration: 600, # default
      passwordMinSize: 8, # default
      passwordMaxSize: 64, # default
      passwordMinTypes: 1, # default
      passwordMinScore: 0, # default
      passwordProhibitedChars: "", # default
      passwordExtraDict: [], # default
      generatePasswordSize: 24, # default
      generatePasswordType: "ascii", # default
      generatePasswordChars: " ", # default
      contactName: value.contact_name,
      contactEmail: value.contact_email,
      contactPhone: value.contact_phone,
    })
  end
end

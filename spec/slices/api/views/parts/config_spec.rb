# frozen_string_literal: true

RSpec.describe API::Views::Parts::Config do
  init_part_spec

  let(:value) { config }
  let(:full_data) {
    {
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
    }
  }
  let(:simple_data) {
    {
      title: value.title,
      description: value.description,
      contact_name: value.contact_name,
      contact_email: value.contact_email,
      contact_phone: value.contact_phone,
    }
  }

  it_behaves_like "full data"

  context "with restricted" do
    let(:opts) { {restricted: true} }

    it_behaves_like "simple data"
  end
end

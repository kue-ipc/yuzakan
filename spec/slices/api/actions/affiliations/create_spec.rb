# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Create do
  init_action_spec

  let(:action_opts) {
    allow(affiliation_repo).to receive_messages(get: nil, set: affiliation)
    {affiliation_repo: affiliation_repo}
  }
  let(:action_params) { affiliation.to_h.except(:id, :created_at, :updated_at) }

  shared_context "when exist" do
    let(:action_opts) {
      allow(affiliation_repo).to receive_messages(get: affiliation)
      {affiliation_repo: affiliation_repo}
    }
  end

  shared_examples "created" do
    it "is created" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/affiliations/#{affiliation.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/affiliations/#{affiliation.name}"
      expect(json[:data]).to eq({
        name: affiliation.name,
        label: affiliation.label,
        note: affiliation.note,
      })
    end

    it "is created without label or note" do
      response = action.call(params.except(:label, :note))
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/affiliations/#{affiliation.name}"
      # 返されるデータはdoubleで返すものなので、ついているものになる。
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/affiliations/#{affiliation.name}"
      expect(json[:data]).to eq({
        name: affiliation.name,
        label: affiliation.label,
        note: affiliation.note,
      })
    end
  end

  shared_examples "failure name duplication" do
    it "is failure name duplication" do
      response = action.call(params)
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["重複しています。"]}})
    end
  end

  shared_examples "failure params" do
    it "is failure without name" do
      response = action.call(params.except(:name))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["存在しません。"]}})
    end

    it "is failure with bad name pattern" do
      response = action.call({**params, name: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["形式が間違っています。"]}})
    end
  end

  shared_examples "create" do
    it_behaves_like "created"
    it_behaves_like "failure params"

    context "when exist" do
      include_context "when exist"
      it_behaves_like "failure params"
      it_behaves_like "failure name duplication"
    end
      end

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
    it_behaves_like "create"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "create"
  end
end

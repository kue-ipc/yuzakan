# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Update do
  init_action_spec

  let(:action_opts) {
    allow(attr_repo).to receive_messages(set: attr,
      get_with_mappings_and_services: attr, renumber_order: 0)
    allow(attr_repo).to receive(:exist?).with("attr42").and_return(true)
    allow(attr_repo).to receive(:exist?).with("hoge").and_return(false)
    allow(attr_repo).to receive(:exist?).with("fuga").and_return(true)
    allow(attr_repo).to receive(:transaction).and_yield
    allow(mapping_repo).to receive_messages(create: mapping,
      update_by_attr_id_and_service_id: mapping,
      delete_by_attr_id_and_service_id: [mapping])
    allow(service_repo).to receive_messages(all: [mapping.service])
    {
      attr_repo: attr_repo,
      mapping_repo: mapping_repo,
      service_repo: service_repo,
    }
  }

  let(:action_params) {
    {
      id: "attr42",
      **struct_to_hash(attr, except: [:name, :mappings]),
      mappings: [struct_to_hash(mapping, except: [:attr])],
    }
  }

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

    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
      })
    end

    context "when not exist" do
      let(:action_opts) {
        allow(attr_repo).to receive_messages(exist?: nil)
        {attr_repo: attr_repo, service_repo: service_repo}
      }

      it_behaves_like "not found"
    end

    it "is ok with different name" do
      response = action.call({**params, name: "hoge"})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
      })
    end

    it "is failure with different name that exsits" do
      response = action.call({**params, name: "fuga"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["重複しています。"]}})
    end
  end
end

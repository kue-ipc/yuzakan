# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Create do
  init_action_spec

  let(:action_opts) {
    allow(affiliation_repo).to receive(:set!).with(affiliation.name, **affiliation_params).and_return(affiliation)
    allow(affiliation_repo).to receive(:set!).with(affiliation.name).and_return(affiliation_without_params)
    {affiliation_repo: affiliation_repo}
  }
  let(:action_params) { {name: affiliation.name, **affiliation_params} }

  let(:affiliation_params) {
    {
      note: affiliation.note,
      attrs: affiliation.attrs,
    }
  }

  let(:affiliation_without_params) { Factory.structs[:affiliation_without_params, name: affiliation.name] }

  shared_context "when exist" do
    let(:action_opts) {
      allow(affiliation_repo).to(
        receive(:set!).with(affiliation.name, **affiliation_params).and_raise(Yuzakan::DB::Repo::DuplicateNameError))
      {affiliation_repo: affiliation_repo}
    }
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Location"]).to eq "/api/affiliations/#{affiliation.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        name: affiliation.name,
        label: affiliation.label,
        note: affiliation.note,
        attrs: affiliation.attrs,
      })
    end

    context "when without no param" do
      let(:affiliation_params) { {} }

      it "is ok without label or note" do
        response = action.call(params)
        expect(response).to be_successful
        expect(response.status).to eq 201
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        expect(response.headers["Location"]).to eq "/api/affiliations/#{affiliation.name}"
        json = JSON.parse(response.body.first, symbolize_names: true)
        # 返されるデータはdoubleで返すものなので、ついているものになる。
        expect(json).to eq({
          name: affiliation.name,
          label: "",
          note: "",
          attrs: {},
        })
      end
    end
  end

  shared_examples "failure name duplication" do
    it "is failure name duplication" do
      response = action.call(params)
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {name: ["重複しています。"]},
      })
    end
  end

  shared_examples "failure params" do
    it "is failure without name" do
      response = action.call(params.except(:name))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {name: ["存在しません。"]},
      })
    end

    it "is failure with bad name pattern" do
      response = action.call({**params, name: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {name: ["形式が間違っています。"]},
      })
    end
  end

  shared_examples "create" do
    it_behaves_like "ok"
    it_behaves_like "failure params"

    context "when exist" do
      include_context "when exist"
      it_behaves_like "failure params"
      it_behaves_like "failure name duplication"
    end
  end

  it_behaves_like "unauthorized"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "unauthorized"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "unauthorized"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "create"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "create"
  end

  context "when logout" do
    include_context "when logout"
    it_behaves_like "unauthenticated"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "unauthenticated"
  end

  context "when timeover" do
    include_context "when timeover"
    it_behaves_like "session timeout"
  end
end

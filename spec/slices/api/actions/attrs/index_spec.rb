# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Index do
  init_action_spec

  let(:another_attr) { Factory.structs[:another_attr] }

  let(:action_opts) {
    allow(attr_repo).to receive(:all).with(no_args).and_return([attr, another_attr])
    allow(attr_repo).to receive(:all).with(page: 1, per_page: 1).and_return([attr])
    allow(attr_repo).to receive(:exposed_all).with(no_args).and_return([attr])
    allow(attr_repo).to receive(:exposed_all).with(page: 1, per_page: 1).and_return([attr])
    {attr_repo: attr_repo}
  }

  # shares

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq [
        attr.to_h.slice(:name, :label, :category, :type),
        another_attr.to_h.slice(:name, :label, :category, :type),
      ]
    end

    it "is ok with pagination" do
      response = action.call({**params, page: 1, per_page: 1})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq [
        attr.to_h.slice(:name, :label, :category, :type),
      ]
    end
  end

  shared_examples "ok only exposed" do
    it "is ok only exposed" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq [
        attr.to_h.slice(:name, :label, :category, :type),
      ]
    end

    it "is ok only exposed with pagination" do
      response = action.call({**params, page: 1, per_page: 1})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq [
        attr.to_h.slice(:name, :label, :category, :type),
      ]
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
  end

  shared_examples "index restrict" do
    it_behaves_like "ok only exposed"
  end

  # test cases

  it_behaves_like "index restrict"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "index"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "index"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "index"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "index"
  end
end

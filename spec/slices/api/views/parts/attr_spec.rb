# frozen_string_literal: true

# NOTE: get an entry combined with grandchildren from repo, so :db is required
RSpec.describe API::Views::Parts::Attr, :db do
  init_part_spec

  let(:value) {
    # Cannot use Factory::Struct, becaus it does not have grandchild associations
    Hanami.app["repos.attr_repo"].get_with_mappings_and_services(Factory[:mapping].attr.name)
  }

  shared_examples "limited data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq({
        name: value.name,
        label: value.label,
        category: value.category,
        type: value.type,
      })
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        name: value.name,
        label: value.label,
        category: value.category,
        type: value.type,
      })
    end
  end

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data.except(:mappings)).to eq({
        name: value.name,
        label: value.label,
        description: value.description,
        category: value.category,
        type: value.type,
        order: value.order,
        hidden: value.hidden,
        readonly: value.readonly,
        code: value.code,
      })
      expcetd_mappings = value.mappings.map do |mapping|
        {
          key: mapping.key,
          type: mapping.type,
          params: mapping.params,
          service: mapping.service.name,
        }
      end
      expect(data[:mappings]).to match_array(expcetd_mappings)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data.except(:mappings)).to eq({
        name: value.name,
        label: value.label,
        description: value.description,
        category: value.category,
        type: value.type,
        order: value.order,
        hidden: value.hidden,
        readonly: value.readonly,
        code: value.code,
      })
      expcetd_mappings = value.mappings.map do |mapping|
        {
          key: mapping.key,
          type: mapping.type,
          params: mapping.params,
          service: mapping.service.name,
        }
      end
      expect(data[:mappings]).to match_array(expcetd_mappings)
    end
  end

  it_behaves_like "full data"

  context "with restricted" do
    let(:opts) { {restricted: true} }

    it_behaves_like "limited data"
  end

  context "with simplified" do
    let(:opts) { {simplified: true} }

    it_behaves_like "simple data"
  end

  context "with restricted and simplified" do
    let(:opts) { {restricted: true, simplified: true} }

    it_behaves_like "simple data"
  end
end

# frozen_string_literal: true

RSpec.describe API::Views::Parts::Attr do
  init_part_spec

  let(:value) {
    create_struct(:attr, mappings: [create_struct(:mapping)])
  }

  it "to_h" do
    hash = subject.to_h
    expect(hash).to eq({
      name: "attr",
      label: "属性",
      group: false,
      primary: false,
      params: {schema: {
        type: "object",
        properties: {
          str: {type: "string", maxLength: 255},
          text: {type: "string"},
          int: {type: "integer"},
          float: {type: "number"},
          bool: {type: "boolean"},
          date: {type: "date"},
          time: {type: "time"},
          datetime: {type: "datetime"},
        },
        required: [],
      }},
    })
  end

  it "to_h with simple" do
    hash = subject.to_h(simple: true)
    expect(hash).to eq({
      name: "attr",
      label: "属性",
    })
  end

  it "to_json" do
    json = JSON.parse(subject.to_json, symbolize_names: true)
    expect(json).to eq({
      name: "attr",
      label: "属性",
      group: false,
      primary: false,
      params: {schema: {
        type: "object",
        properties: {
          str: {type: "string", maxLength: 255},
          text: {type: "string"},
          int: {type: "integer"},
          float: {type: "number"},
          bool: {type: "boolean"},
          date: {type: "date"},
          time: {type: "time"},
          datetime: {type: "datetime"},
        },
        required: [],
      }},
    })
  end

  it "to_json with simple" do
    json = JSON.parse(subject.to_json(simple: true), symbolize_names: true)
    expect(json).to eq({
      name: "attr",
      label: "属性",
    })
  end
end

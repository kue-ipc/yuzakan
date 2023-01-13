# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Web.routes do
  let(:routes) { Web.routes }

  it 'generates "/"' do
    actual = routes.path(:root)
    expect(actual).to eq('/')
  end
end

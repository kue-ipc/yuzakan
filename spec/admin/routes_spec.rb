# frozen_string_literal: true

require_relative '../spec_helper'

describe Web.routes do
  let(:routes) { Web.routes }

  it 'generates "/"' do
    actual = routes.path(:root)
    actual.must_equal('/')
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::Views::ApplicationLayout do
  let(:layout)   { Api::Views::ApplicationLayout.new({format: :html}, 'contents') }
  let(:rendered) { layout.render }

  it 'contains application name' do
    expect(rendered).must_include('Api')
  end
end

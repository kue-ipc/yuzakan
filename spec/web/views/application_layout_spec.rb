# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Web::Views::ApplicationLayout do
  let(:layout)   { Web::Views::ApplicationLayout.new({format: :html}, 'contents') }
  let(:rendered) { layout.render }

  # it 'contains application name' do
  #   expect(rendered).must_include('Web')
  # end
end

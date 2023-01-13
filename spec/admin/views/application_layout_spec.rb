# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::Views::ApplicationLayout do
  let(:layout)   { Admin::Views::ApplicationLayout.new({format: :html}, 'contents') }
  let(:rendered) { layout.render }

  # it 'contains application name' do
  #   expect(rendered).must_include('Admin')
  # end
end

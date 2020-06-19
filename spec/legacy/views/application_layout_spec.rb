# frozen_string_literal: true

require 'spec_helper'

describe Legacy::Views::ApplicationLayout do
  let(:exposures) { Hash[format: :html, current_config: nil] }
  let(:layout)   { Legacy::Views::ApplicationLayout.new(exposures, 'contents') }
  let(:rendered) { layout.render }

  # テストできないのでは？
  # it 'contains application name' do
  #   _(rendered).must_include('Legacy')
  # end
end

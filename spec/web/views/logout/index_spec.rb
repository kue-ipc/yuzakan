# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Views::Logout::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/logout/index.html.slim') }
  let(:view)      { Web::Views::Logout::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

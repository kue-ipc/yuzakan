# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Legacy::Views::Dashboard::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/legacy/templates/dashboard/index.html.slim') }
  let(:view)      { Legacy::Views::Dashboard::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

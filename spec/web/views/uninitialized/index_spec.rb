# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Views::Uninitialized::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/uninitialized/index.html.slim') }
  let(:view)      { Web::Views::Uninitialized::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

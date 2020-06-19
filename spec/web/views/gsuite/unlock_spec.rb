# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Views::Gsuite::Unlock do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/gsuite/unlock.html.slim') }
  let(:view)      { Web::Views::Gsuite::Unlock.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

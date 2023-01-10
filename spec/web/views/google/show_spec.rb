# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Views::Google::Show do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/google/show.html.slim') }
  let(:view)      { Web::Views::Google::Show.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

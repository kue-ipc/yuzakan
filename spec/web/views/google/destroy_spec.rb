# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Web::Views::Google::Destroy do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/google/destroy.html.slim') }
  let(:view)      { Web::Views::Google::Destroy.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

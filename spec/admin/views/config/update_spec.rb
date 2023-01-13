# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Views::Config::Update do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/config/update.html.slim') }
  let(:view)      { Admin::Views::Config::Update.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

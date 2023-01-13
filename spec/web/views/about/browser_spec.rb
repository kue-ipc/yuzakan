# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Web::Views::About::Browser do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/about/browser.html.slim') }
  let(:view)      { Web::Views::About::Browser.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

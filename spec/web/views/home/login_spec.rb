# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Views::Home::Login do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/home/login.html.slim') }
  let(:view)      { Web::Views::Home::Login.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

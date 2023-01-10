# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Views::Config::Import do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/config/import.html.slim') }
  let(:view)      { Admin::Views::Config::Import.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

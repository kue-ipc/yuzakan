# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Views::Setup::New do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/setup/new.html.slim') }
  let(:view)      { Admin::Views::Setup::New.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Views::Providers::Index do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/providers/index.html.slim') }
  let(:view)      { Admin::Views::Providers::Index.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).must_equal exposures.fetch(:format)
  end
end

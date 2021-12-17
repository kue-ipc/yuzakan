require_relative '../../../spec_helper'

describe Admin::Views::Providers::New do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/providers/new.html.slim') }
  let(:view)      { Admin::Views::Providers::New.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

require_relative '../../../spec_helper'

describe Admin::Views::Providers::New do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/admin/templates/providers/new.html.slim')
  end
  let(:view)      { Admin::Views::Providers::New.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

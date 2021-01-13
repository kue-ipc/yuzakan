require_relative '../../../spec_helper'

describe Admin::Views::Providers::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/providers/create.html.slim') }
  let(:view)      { Admin::Views::Providers::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

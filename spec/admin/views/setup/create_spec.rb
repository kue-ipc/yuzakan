require_relative '../../../spec_helper'

describe Admin::Views::Setup::Create do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/setup/create.html.slim') }
  let(:view)      { Admin::Views::Setup::Create.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

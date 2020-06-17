require_relative '../../../spec_helper'

describe Admin::Views::AttrTypes::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/attr_types/create.html.slim') }
  let(:view)      { Admin::Views::AttrTypes::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

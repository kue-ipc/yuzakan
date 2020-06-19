require_relative '../../../spec_helper'

describe Admin::Views::AttrTypes::Update do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/attr_types/update.html.slim') }
  let(:view)      { Admin::Views::AttrTypes::Update.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

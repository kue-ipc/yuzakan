require_relative '../../../spec_helper'

describe Admin::Views::Attrs::Update do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/admin/templates/attrs/update.html.slim')
  end
  let(:view)      { Admin::Views::Attrs::Update.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

require_relative '../../../spec_helper'

describe Admin::Views::Attrs::Destroy do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/attrs/destroy.html.slim') }
  let(:view)      { Admin::Views::Attrs::Destroy.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

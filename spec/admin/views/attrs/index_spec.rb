require_relative '../../../spec_helper'

describe Admin::Views::Attrs::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/attrs/index.html.slim') }
  let(:view)      { Admin::Views::Attrs::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

require_relative '../../../spec_helper'

describe Admin::Views::Adapters::Params::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/adapters/params/index.html.slim') }
  let(:view)      { Admin::Views::Adapters::Params::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

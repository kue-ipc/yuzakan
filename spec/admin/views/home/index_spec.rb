require_relative '../../../spec_helper'

describe Admin::Views::Home::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/admin/templates/home/index.html.slim')
  end
  let(:view)      { Admin::Views::Home::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

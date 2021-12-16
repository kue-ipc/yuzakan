require_relative '../../../spec_helper'

describe Web::Views::Maintenance::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/maintenance/index.html.slim')
  end
  let(:view)      { Web::Views::Maintenance::Index.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

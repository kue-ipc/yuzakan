require_relative '../../../spec_helper'

describe Legacy::Views::About::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/legacy/templates/about/index.html.slim')
  end
  let(:view)      { Legacy::Views::About::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

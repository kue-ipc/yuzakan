require_relative '../../../spec_helper'

describe Legacy::Views::About::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/legacy/templates/about/index.html.slim') }
  let(:view)      { Legacy::Views::About::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

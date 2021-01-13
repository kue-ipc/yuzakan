require_relative '../../../spec_helper'

describe Web::Views::Gsuite::Show do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/gsuite/show.html.slim')
  end
  let(:view)      { Web::Views::Gsuite::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

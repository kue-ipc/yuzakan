require_relative '../../../../spec_helper'

describe Web::Views::Gsuite::Code::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/gsuite/code/create.html.slim')
  end
  let(:view)      { Web::Views::Gsuite::Code::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

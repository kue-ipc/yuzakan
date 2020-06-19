require_relative '../../../spec_helper'

describe Web::Views::Gsuite::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/gsuite/create.html.slim') }
  let(:view)      { Web::Views::Gsuite::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

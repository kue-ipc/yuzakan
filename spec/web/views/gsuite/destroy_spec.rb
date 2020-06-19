require_relative '../../../spec_helper'

describe Web::Views::Gsuite::Destroy do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/gsuite/destroy.html.slim') }
  let(:view)      { Web::Views::Gsuite::Destroy.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

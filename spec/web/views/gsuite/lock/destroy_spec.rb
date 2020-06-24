require_relative '../../../spec_helper'

describe Web::Views::Gsuite::Lock::Destroy do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/gsuite/lock/destroy.html.slim') }
  let(:view)      { Web::Views::Gsuite::Lock::Destroy.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

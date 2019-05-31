require_relative '../../../spec_helper'

describe Admin::Views::Providers::Destroy do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/providers/destroy.html.slim') }
  let(:view)      { Admin::Views::Providers::Destroy.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

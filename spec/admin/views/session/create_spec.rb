require_relative '../../../spec_helper'

describe Admin::Views::Session::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/session/create.html.slim') }
  let(:view)      { Admin::Views::Session::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

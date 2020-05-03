require_relative '../../../spec_helper'

describe Legacy::Views::Session::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/legacy/templates/session/create.html.slim') }
  let(:view)      { Legacy::Views::Session::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

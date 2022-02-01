require_relative '../../../spec_helper'

describe Api::Views::Session::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/api/templates/session/create.html.slim') }
  let(:view)      { Api::Views::Session::Create.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

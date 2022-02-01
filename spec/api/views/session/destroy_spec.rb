require_relative '../../../spec_helper'

describe Api::Views::Session::Destroy do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/api/templates/session/destroy.html.slim') }
  let(:view)      { Api::Views::Session::Destroy.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

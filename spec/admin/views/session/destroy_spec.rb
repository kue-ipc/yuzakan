require_relative '../../../spec_helper'

describe Admin::Views::Session::Destroy do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/session/destroy.html.slim') }
  let(:view)      { Admin::Views::Session::Destroy.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

require_relative '../../../spec_helper'

describe Admin::Views::Users::New do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/users/new.html.slim') }
  let(:view)      { Admin::Views::Users::New.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

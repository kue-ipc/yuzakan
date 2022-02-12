require_relative '../../../spec_helper'

describe Admin::Views::Users::Destroy do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/users/destroy.html.slim') }
  let(:view)      { Admin::Views::Users::Destroy.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

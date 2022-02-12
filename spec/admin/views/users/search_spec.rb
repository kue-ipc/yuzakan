require_relative '../../../spec_helper'

describe Admin::Views::Users::Search do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/users/search.html.slim') }
  let(:view)      { Admin::Views::Users::Search.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

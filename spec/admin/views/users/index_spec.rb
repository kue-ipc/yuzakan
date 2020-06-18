require_relative '../../../spec_helper'

describe Admin::Views::Users::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/users/index.html.slim') }
  let(:view)      { Admin::Views::Users::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

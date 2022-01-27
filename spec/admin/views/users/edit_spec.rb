require_relative '../../../spec_helper'

describe Admin::Views::Users::Edit do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/users/edit.html.slim') }
  let(:view)      { Admin::Views::Users::Edit.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

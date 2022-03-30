require_relative '../../../spec_helper'

describe Admin::Views::Setup::Show do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/setup/show.html.slim') }
  let(:view)      { Admin::Views::Setup::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

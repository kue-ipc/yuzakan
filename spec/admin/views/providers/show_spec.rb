require_relative '../../../spec_helper'

describe Admin::Views::Providers::Show do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/providers/show.html.slim') }
  let(:view)      { Admin::Views::Providers::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

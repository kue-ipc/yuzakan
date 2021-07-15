require_relative '../../../spec_helper'

describe Admin::Views::Config::Export do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/config/export.html.slim') }
  let(:view)      { Admin::Views::Config::Export.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end
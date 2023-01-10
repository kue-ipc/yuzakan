require_relative '../../../spec_helper'

describe Admin::Views::Config::New do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/config/new.html.slim') }
  let(:view)      { Admin::Views::Config::New.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

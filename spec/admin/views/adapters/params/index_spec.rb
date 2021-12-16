require_relative '../../../../spec_helper'

describe Admin::Views::Adapters::Params::Index do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/admin/templates/adapters/params/index.html.slim')
  end
  let(:view) do
    Admin::Views::Adapters::Params::Index.new(template, **exposures)
  end
  let(:rendered) { view.render }

  # it 'exposes #format' do
  #   _(view.format).must_equal exposures.fetch(:format)
  # end
end

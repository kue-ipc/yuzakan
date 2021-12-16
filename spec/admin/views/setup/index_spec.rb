require_relative '../../../spec_helper'

describe Admin::Views::Setup::Index do
  let(:exposures) do
    {
      format: :html,
      params: {},
      flash: {},
      current_config: nil,
    }
  end
  let(:template) do
    Hanami::View::Template.new('apps/admin/templates/setup/index.html.slim')
  end
  let(:view)      { Admin::Views::Setup::Index.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end

  it 'exist form' do
    _(rendered).must_match %(<form)
  end
end

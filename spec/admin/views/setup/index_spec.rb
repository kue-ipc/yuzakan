# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Views::Setup::Index do
  let(:exposures) do
    {
      format: :html,
      params: {},
      flash: {},
      current_config: nil,
      current_theme: DEFAULT_THEME,
    }
  end
  let(:template)  {
    Hanami::View::Template.new('apps/admin/templates/setup/index.html.slim')
  }
  let(:view)      { Admin::Views::Setup::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end

  it 'exist form' do
    rendered.must_match %(<form)
  end
end

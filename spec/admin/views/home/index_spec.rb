# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Views::Home::Index do
  let(:exposures) { {format: :html, current_config: ConfigRepository.new.current, flash: {}, params: {}} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/home/index.html.slim') }
  let(:view)      { Admin::Views::Home::Index.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).must_equal exposures.fetch(:format)
  end

  # it 'exist form' do
  #   expect(rendered).must_match %(<form)
  # end
end

# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Views::Groups::Show do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/groups/show.html.slim') }
  let(:view)      { Admin::Views::Groups::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

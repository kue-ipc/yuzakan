# frozen_string_literal: true

RSpec.describe Admin::Views::Groups::Index do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/groups/index.html.slim') }
  let(:view)      { Admin::Views::Groups::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

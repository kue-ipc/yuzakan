# frozen_string_literal: true

RSpec.describe Admin::Views::Groups::Show do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/groups/show.html.slim') }
  let(:view)      { Admin::Views::Groups::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

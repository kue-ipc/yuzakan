# frozen_string_literal: true

RSpec.describe Admin::Views::Providers::Show do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/providers/show.html.slim') }
  let(:view)      { Admin::Views::Providers::Show.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

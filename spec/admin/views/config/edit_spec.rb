# frozen_string_literal: true

RSpec.describe Admin::Views::Config::Edit do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/config/edit.html.slim') }
  let(:view)      { Admin::Views::Config::Edit.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

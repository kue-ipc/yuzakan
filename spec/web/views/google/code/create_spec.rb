# frozen_string_literal: true

RSpec.describe Web::Views::Google::Code::Create do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/google/code/create.html.slim') }
  let(:view)      { Web::Views::Google::Code::Create.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

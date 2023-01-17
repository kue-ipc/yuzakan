# frozen_string_literal: true

RSpec.describe Web::Views::User::Show do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/user/show.html.slim') }
  let(:view)      { Web::Views::User::Show.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

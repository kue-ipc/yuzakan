# frozen_string_literal: true

RSpec.describe Web::Views::User::Password::Update, type: :view do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new("apps/web/templates/user/password/update.html.slim") }
  let(:view)      { described_class.new(template, exposures) }
  let(:rendered)  { view.render }

  it "exposes #format" do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

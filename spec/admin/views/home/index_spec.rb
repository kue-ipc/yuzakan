# frozen_string_literal: true

RSpec.describe Admin::Views::Home::Index, type: :view do
  let(:exposures) { {format: :html, current_config: ConfigRepository.new.current, flash: {}, params: {}} }
  let(:template)  { Hanami::View::Template.new("apps/admin/templates/home/index.html.slim") }
  let(:view)      { described_class.new(template, exposures) }
  let(:rendered)  { view.render }

  it "exposes #format" do
    expect(view.format).to eq exposures.fetch(:format)
  end

  # it 'exist form' do
  #   expect(rendered).to match %(<form)
  # end
end

# frozen_string_literal: true

RSpec.describe Admin::Views::Config::Replace do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/config/replace.html.slim') }
  let(:view)      { Admin::Views::Config::Replace.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end

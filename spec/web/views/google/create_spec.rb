require_relative '../../../spec_helper'

describe Web::Views::Google::Create do
  let(:exposures) { {format: :html} }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/google/create.html.slim')
  end
  let(:view)      { Web::Views::Google::Create.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

require_relative '../../../spec_helper'

describe Web::Views::Google::Destroy do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/google/destroy.html.slim')
  end
  let(:view)      { Web::Views::Google::Destroy.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

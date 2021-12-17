require_relative '../../../../spec_helper'

describe Web::Views::Google::Lock::Destroy do
  let(:exposures) { {format: :html} }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/google/lock/destroy.html.slim')
  end
  let(:view)      { Web::Views::Google::Lock::Destroy.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

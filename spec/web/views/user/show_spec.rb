require_relative '../../../spec_helper'

describe Web::Views::User::Show do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/user/show.html.slim')
  end
  let(:view)      { Web::Views::User::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

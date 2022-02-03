require_relative '../../../spec_helper'

describe Api::Views::Account::Show do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/api/templates/account/show.html.slim') }
  let(:view)      { Api::Views::Account::Show.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

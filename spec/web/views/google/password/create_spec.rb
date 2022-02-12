require_relative '../../../../spec_helper'

describe Web::Views::Google::Password::Create do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/google/password/create.html.slim') }
  let(:view) {
    Web::Views::Google::Password::Create.new(template, **exposures)
  }
  let(:rendered) { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

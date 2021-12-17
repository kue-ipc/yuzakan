require_relative '../../../../spec_helper'

describe Web::Views::User::Password::Edit do
  let(:exposures) { {format: :html} }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/user/password/edit.html.slim')
  end
  let(:view)      { Web::Views::User::Password::Edit.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

require_relative '../../../../spec_helper'

describe Legacy::Views::User::Password::Edit do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/legacy/templates/user/password/edit.html.slim')
  end
  let(:view) do
    Legacy::Views::User::Password::Edit.new(template, exposures)
  end
  let(:rendered) { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

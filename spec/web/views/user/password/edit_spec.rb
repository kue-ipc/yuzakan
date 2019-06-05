require_relative '../../../spec_helper'

describe Web::Views::User::Password::Edit do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/user/password/edit.html.slim') }
  let(:view)      { Web::Views::User::Password::Edit.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

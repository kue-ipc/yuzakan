require_relative '../../../spec_helper'

describe Web::Views::User::ChangePassword do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/user/change_password.html.slim') }
  let(:view)      { Web::Views::User::ChangePassword.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

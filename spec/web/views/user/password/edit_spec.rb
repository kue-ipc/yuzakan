# frozen_string_literal: true

require_relative '../../../../spec_helper'

RSpec.describe Web::Views::User::Password::Edit do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/user/password/edit.html.slim') }
  let(:view)      { Web::Views::User::Password::Edit.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).must_equal exposures.fetch(:format)
  end
end

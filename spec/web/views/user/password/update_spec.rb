# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Web::Views::User::Password::Update do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/user/password/update.html.slim') }
  let(:view)      { Web::Views::User::Password::Update.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

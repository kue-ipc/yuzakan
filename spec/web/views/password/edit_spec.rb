require_relative '../../../spec_helper'

describe Web::Views::Password::Edit do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/password/edit.html.slim') }
  let(:view)      { Web::Views::Password::Edit.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

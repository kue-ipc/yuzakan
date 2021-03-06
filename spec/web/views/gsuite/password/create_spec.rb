require_relative '../../../../spec_helper'

describe Web::Views::Gsuite::Password::Create do
  let(:exposures) { Hash[format: :html] }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/gsuite/password/create.html.slim')
  end
  let(:view) do
    Web::Views::Gsuite::Password::Create.new(template, exposures)
  end
  let(:rendered) { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end

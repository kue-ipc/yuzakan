# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Views::Setup::Done do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/setup/done.html.slim') }
  let(:view)      { Admin::Views::Setup::Done.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    view.format.must_equal exposures.fetch(:format)
  end
end

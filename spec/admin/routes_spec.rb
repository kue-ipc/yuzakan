# frozen_string_literal: true

RSpec.describe Web.routes do
  let(:routes) { Web.routes }

  it 'generates "/"' do
    actual = routes.path(:root)
    expect(actual).to eq('/')
  end
end

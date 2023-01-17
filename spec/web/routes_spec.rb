# frozen_string_literal: true

RSpec.describe Admin.routes do
  let(:routes) { Admin.routes }

  it 'generates "/"' do
    actual = routes.path(:root)
    expect(actual).to eq('/admin')
  end
end

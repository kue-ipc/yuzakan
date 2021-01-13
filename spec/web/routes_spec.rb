require_relative '../spec_helper'

describe Admin.routes do
  let(:routes) { Admin.routes }

  it 'generates "/"' do
    actual = routes.path(:root)
    _(actual).must_equal('/admin')
  end
end

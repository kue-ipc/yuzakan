require_relative '../spec_helper'

describe Web.routes do
  let(:routes) { Web.routes }

  it 'generates "/"' do
    actual = routes.path(:root)
    _(actual).must_equal('/')
  end
end

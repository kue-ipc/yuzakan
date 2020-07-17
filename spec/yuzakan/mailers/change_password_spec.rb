require_relative '../../spec_helper'

describe Mailers::ChangePassword do
  let(:config) { ConfigRepository.new.current }
  let(:user) { Authenticate.new(client: '::1').call(auth).user }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'delivers email' do
    mail = Mailers::ChangePassword.deliver(user: user, config: config)
    _(mail.to).must_equal ['user@yuzakan.test']
    print '----'
    print mail.body.parts.first.decoded
    print '----'

  end
end

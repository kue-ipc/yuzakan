require_relative '../../../spec_helper'

describe Admin::Controllers::Dashboard::Index do
  describe 'remote ip' do
    let(:action) { Admin::Controllers::Dashboard::Index.new }
    let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
    let(:session) { {user_id: user_id, access_time: Time.now} }
    let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
    let(:auth) { {username: 'admin', password: 'pass'} }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(action.send(:remote_ip).to_s).must_equal '::1'
    end

    describe 'check remote ip' do
      before do
        UpdateConfig.new.call(
          remote_ip_header: 'X-Forwarded-For',
          trusted_reverse_proxies: '::1 127.0.0.1')
      end
      after { db_reset }

      it 'remote_ip is not ::1' do
        response = action.call(params.merge(
                                 'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
        _(response[0]).must_equal 200
        _(action.send(:remote_ip).to_s).must_equal '192.168.1.1'
      end

      it 'remote_ip is not 127.0.0.1' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '127.0.0.1',
                                 'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
        _(response[0]).must_equal 200
        _(action.send(:remote_ip).to_s).must_equal '192.168.1.1'
      end

      it 'remote_ip is first' do
        response = action.call(params.merge(
                                 'HTTP_X_FORWARDED_FOR' =>
                                   '192.168.10.10, 192.168.20.20, 192.168.30.30'))
        _(response[0]).must_equal 200
        _(action.send(:remote_ip).to_s).must_equal '192.168.10.10'
      end

      it 'fake remote_ip' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '203.0.113.1',
                                 'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
        _(response[0]).must_equal 200
        _(action.send(:remote_ip).to_s).must_equal '203.0.113.1'
      end

      it 'other remote_ip' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '203.0.113.1'))
        _(response[0]).must_equal 200
        _(action.send(:remote_ip).to_s).must_equal '203.0.113.1'
      end
    end

    # describe 'check x-real-ip' do
    #   before do
    #     UpdateConfig.new.call(
    #       remote_ip_header: 'X-Real-Ip',
    #       trusted_reverse_proxies: '::1 127.0.0.1')
    #   end
    #   after { db_reset }

    #   it 'remote_ip is not ::1' do
    #     response = action.call(params.merge(
    #                             'HTTP_X_REAL_IP' => '192.168.1.1'))
    #     _(response[0]).must_equal 200
    #     _(action.send(:remote_ip).to_s).must_equal '192.168.1.1'
    #   end
    # end
  end
end

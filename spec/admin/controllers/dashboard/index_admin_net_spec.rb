# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Dashboard::Index do
  describe 'admin net' do
    let(:action) { Admin::Controllers::Dashboard::Index.new }
    let(:params) { {'rack.session' => session} }
    let(:session) { {user_id: user_id, access_time: Time.now} }
    let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
    let(:auth) { {username: 'admin', password: 'pass'} }

    before { UpdateConfig.new.call(admin_networks: '192.168.1.0/24') }
    after { db_reset }

    it 'is successful in network' do
      response = action.call(params.merge(
                               'REMOTE_ADDR' => '192.168.1.1'))
      _(response[0]).must_equal 200
    end

    it 'is failure out network' do
      response = action.call(params.merge(
                               'REMOTE_ADDR' => '192.168.2.1'))
      _(response[0]).must_equal 403
    end

    describe 'reverse proxy' do
      before do
        UpdateConfig.new.call(
          remote_ip_header: 'X-Forwarded-For',
          trusted_reverse_proxies: '::1 127.0.0.1')
      end
      after { db_reset }

      it 'reverse is successful in network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '::1',
                                 'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
        _(response[0]).must_equal 200
      end

      it 'reverse is failure out network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '::1',
                                 'HTTP_X_FORWARDED_FOR' => '192.168.2.1'))
        _(response[0]).must_equal 403
      end

      it 'not reverse is successful in network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '192.168.1.1'))
        _(response[0]).must_equal 200
      end

      it 'not reverse is failure out network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '192.168.2.1'))
        _(response[0]).must_equal 403
      end

      it 'not reverse and fake is failure fake in network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '203.0.113.1',
                                 'HTTP_X_FORWARDED_FOR' => '192.168.2.1'))
        _(response[0]).must_equal 403
      end

      it 'not reverse and fake is failure fake out network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '203.0.113.1',
                                 'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
        _(response[0]).must_equal 403
      end

      it 'remote_ip is first in network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '::1',
                                 'HTTP_X_FORWARDED_FOR' =>
                                   '192.168.1.1, 192.168.2.2, 192.168.3.3'))
        _(response[0]).must_equal 200
      end
    end

    # describe 'check x-real-ip' do
    #   before do
    #     UpdateConfig.new.call(
    #       remote_ip_header: 'X-Real-Ip',
    #       trusted_reverse_proxies: '::1 127.0.0.1')
    #   end
    #   after { db_reset }

    #   it 'is successful x-real-ip' do
    #     response = action.call(params.merge(
    #                             'REMOTE_ADDR' => '127.0.0.1',
    #                             'HTTP_X_REAL_IP' => '192.168.1.1'))
    #     _(response[0]).must_equal 200
    #   end

    #   it 'is failure x-real-ip' do
    #     response = action.call(params.merge(
    #                             'REMOTE_ADDR' => '127.0.0.1',
    #                             'HTTP_X_REAL_IP' => '192.168.2.1'))
    #     _(response[0]).must_equal 403
    #   end
    # end

    describe 'multi network' do
      before do
        UpdateConfig.new.call(
          admin_networks: '192.168.1.0/24 192.168.2.10 fd00:1234::/64')
      end
      after { db_reset }

      it 'is successful in network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '192.168.1.1'))
        _(response[0]).must_equal 200
      end

      it 'is successful in just' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '192.168.2.10'))
        _(response[0]).must_equal 200
      end

      it 'is successful in ipv6 network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => 'fd00:1234::5678:9abc'))
        _(response[0]).must_equal 200
      end

      it 'is failure not match' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '192.168.2.1'))
        _(response[0]).must_equal 403
      end

      it 'is failure out network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => '10.1.1.1'))
        _(response[0]).must_equal 403
      end

      it 'is failure out ipv6 network' do
        response = action.call(params.merge(
                                 'REMOTE_ADDR' => 'fd00:5678::1122:3344'))
        _(response[0]).must_equal 403
      end
    end
  end
end

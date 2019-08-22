# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Controllers::Dashboard::Index do
  let(:action) { Web::Controllers::Dashboard::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
    action.send(:remote_ip).to_s.must_equal '::1'
  end

  describe 'check remote ip' do
    before { UpdateConfig.new.call(
      remote_ip_header: 'X-Forwarded-For',
      trusted_reverse_proxies: '::1 127.0.0.1') }
    after { db_reset }

    it 'remote_ip is not ::1' do
      response = action.call(params.merge(
        'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.1.1'
    end

    it 'remote_ip is not 127.0.0.1' do
      response = action.call(params.merge(
        'REMOTE_ADDR' => '127.0.0.1',
        'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.1.1'
    end

    it 'remote_ip is first' do
      response = action.call(params.merge(
        'HTTP_X_FORWARDED_FOR' =>
          '192.168.10.10, 192.168.20.20, 192.168.30.30'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.10.10'
    end

    it 'fake remote_ip' do
      response = action.call(params.merge(
        'REMOTE_ADDR' => '172.16.1.1',
        'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '172.16.1.1'
    end

    it 'other remote_ip' do
      response = action.call(params.merge(
        'REMOTE_ADDR' => '172.16.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '172.16.1.1'
    end
  end

  describe 'check x-real-ip' do
    before { UpdateConfig.new.call(
      remote_ip_header: 'X-Real-Ip',
      trusted_reverse_proxies: '::1 127.0.0.1') }
    after { db_reset }

    it 'remote_ip is not ::1' do
      response = action.call(params.merge(
        'HTTP_X_REAL_IP' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.1.1'
    end
  end
end
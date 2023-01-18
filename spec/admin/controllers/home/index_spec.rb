# frozen_string_literal: true

RSpec.describe Admin::Controllers::Home::Index, type: :action do
  init_controller_spec

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).to eq 403
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
  end

  describe 'admin' do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:network) { Network.new(**network_attributes, clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    end
  end

  describe 'level matrix' do
    [
      {user_level: 0, network_level: 0, code: 403},
      {user_level: 1, network_level: 0, code: 403},
      {user_level: 2, network_level: 0, code: 403},
      {user_level: 3, network_level: 0, code: 403},
      {user_level: 4, network_level: 0, code: 403},
      {user_level: 5, network_level: 0, code: 403},
      {user_level: 0, network_level: 1, code: 403},
      {user_level: 1, network_level: 1, code: 403},
      {user_level: 2, network_level: 1, code: 403},
      {user_level: 3, network_level: 1, code: 403},
      {user_level: 4, network_level: 1, code: 403},
      {user_level: 5, network_level: 1, code: 403},
      {user_level: 0, network_level: 2, code: 403},
      {user_level: 1, network_level: 2, code: 403},
      {user_level: 2, network_level: 2, code: 200},
      {user_level: 3, network_level: 2, code: 200},
      {user_level: 4, network_level: 2, code: 200},
      {user_level: 5, network_level: 2, code: 200},
      {user_level: 0, network_level: 3, code: 403},
      {user_level: 1, network_level: 3, code: 403},
      {user_level: 2, network_level: 3, code: 200},
      {user_level: 3, network_level: 3, code: 200},
      {user_level: 4, network_level: 3, code: 200},
      {user_level: 5, network_level: 3, code: 200},
      {user_level: 0, network_level: 4, code: 403},
      {user_level: 1, network_level: 4, code: 403},
      {user_level: 2, network_level: 4, code: 200},
      {user_level: 3, network_level: 4, code: 200},
      {user_level: 4, network_level: 4, code: 200},
      {user_level: 5, network_level: 4, code: 200},
      {user_level: 0, network_level: 5, code: 403},
      {user_level: 1, network_level: 5, code: 403},
      {user_level: 2, network_level: 5, code: 200},
      {user_level: 3, network_level: 5, code: 200},
      {user_level: 4, network_level: 5, code: 200},
      {user_level: 5, network_level: 5, code: 200},
    ].each do |pattern|
      describe "user: #{pattern[:user_level]} network: #{pattern[:network_level]}" do
        let(:user) { User.new(**user_attributes, clearance_level: pattern[:user_level]) }
        let(:network) { Network.new(**network_attributes, clearance_level: pattern[:network_level]) }

        if pattern[:code] == 200
          it 'is successful' do
            response = action.call(params)
            expect(response[0]).to eq pattern[:code]
          end
        else
          it 'is failure' do
            response = action.call(params)
            expect(response[0]).to eq pattern[:code]
          end
        end
      end
    end
  end
end

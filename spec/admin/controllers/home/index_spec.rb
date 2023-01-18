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

  level_matrix do |pattern|
    describe "user: #{pattern[:user_level]} network: #{pattern[:network_level]}" do
      let(:user) { User.new(**user_attributes, clearance_level: pattern[:user_level]) }
      let(:network) { Network.new(**network_attributes, clearance_level: pattern[:network_level]) }

      if [pattern[:user_level], pattern[:network_level]].min >= 2
        it 'is successful' do
          response = action.call(params)
          expect(response[0]).to eq 200
        end
      else
        it 'is failure' do
          response = action.call(params)
          expect(response[0]).to eq 403
        end
      end
    end
  end
end

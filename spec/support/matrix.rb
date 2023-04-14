# frozen_string_literal: true

def level_matrix
  describe 'level matrix' do
    6.times do |user_level|
      6.times do |network_level|
        yield({
          user_level: user_level,
          network_level: network_level,
        })
      end
    end
  end
end

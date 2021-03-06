require_relative '../../spec_helper'

describe ConfigRepository do
  let(:repository) { ConfigRepository.new }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'current is nil' do
      _(repository.current).must_be_nil
    end

    it 'initialized? is false' do
      _(repository.initialized?).must_equal false
    end
  end

  it 'current is config after initialized' do
    _(repository.current).wont_be_nil
  end

  it 'initialized? is true after initialized' do
    _(repository.initialized?).must_equal true
  end
end

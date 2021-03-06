require_relative '../../spec_helper'

describe Encrypt do
  let(:interactor) { Encrypt.new(**params) }
  let(:params) { {} }

  it 'encryt text' do
    text = 'Ab01#'
    result = interactor.call({data: text})
    _(result.successful?).must_equal true
    _(result.encrypted).must_match(/\A[\x20-\x7E]*\z/)

    pb_crypt = Yuzakan::Utils::PbCrypt.new(ENV.fetch('DB_SECRET'))
    plain_text = pb_crypt.decrypt_text(result.encrypted)
    _(plain_text).must_equal text
  end

  it 'encryt empty text' do
    text = ''
    result = interactor.call({data: text})
    _(result.successful?).must_equal true
    _(result.encrypted).must_be_empty
  end

  it 'encryt unicode text' do
    text = '日本語😺🀄等'
    result = interactor.call({data: text})
    _(result.successful?).must_equal true
    _(result.encrypted).must_match(/\A[\x20-\x7E]*\z/)
  end

  it 'encryt text other password' do
    text = 'Ab01#'
    result = interactor.call({data: text})
    interactor_other = Encrypt.new(password: 'abc012')
    result_other = interactor_other.call({data: text})
    _(result_other.encrypted).wont_equal result.encrypted
  end

  describe 'max 256' do
    let(:params) { {max: 256} }
    it 'encryt 1..256 size text' do
      (1..256).each do |n|
        text = 'A' * n
        result = interactor.call({data: text})
        if result.encrypted.size <= 255
          _(result.successful?).must_equal true
        else
          _(result.successful?).must_equal false
        end
        _(result.encrypted).must_match(/\A[\x20-\x7E]*\z/)
      end
    end
  end

  describe 'max 4096 * 8' do
    let(:params) { {max: 4096 * 8} }
    it 'encryt 4096 size text' do
      text = 'A' * 4096
      result = interactor.call({data: text})
      _(result.successful?).must_equal true
      _(result.encrypted).must_match(/\A[\x20-\x7E]*\z/)
    end
  end
end

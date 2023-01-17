# frozen_string_literal: true

RSpec.describe Encrypt do
  let(:interactor) { Encrypt.new(**params) }
  let(:params) { {text: true} }

  it 'encryt text' do
    text = 'Ab01#'
    result = interactor.call({data: text})
    expect(result.successful?).to eq true
    expect(result.encrypted).to match(/\A[\x20-\x7E]*\z/)

    pb_crypt = Yuzakan::Utils::PbCrypt.new(ENV.fetch('DB_SECRET'))
    plain_text = pb_crypt.decrypt_text(result.encrypted)
    expect(plain_text).to eq text
  end

  it 'encryt empty text' do
    text = ''
    result = interactor.call({data: text})
    expect(result.successful?).to eq true
    expect(result.encrypted).to be_empty
  end

  it 'encryt unicode text' do
    text = '日本語😺🀄等'
    result = interactor.call({data: text})
    expect(result.successful?).to eq true
    expect(result.encrypted).to match(/\A[\x20-\x7E]*\z/)
  end

  it 'encryt text other password' do
    text = 'Ab01#'
    result = interactor.call({data: text})
    interactor_other = Encrypt.new(password: 'abc012')
    result_other = interactor_other.call({data: text})
    expect(result_other.encrypted).not_to eq result.encrypted
  end

  describe 'max 256' do
    let(:params) { {text: true, max: 256} }
    it 'encryt 1..256 size text' do
      (1..256).each do |n|
        text = 'A' * n
        result = interactor.call({data: text})
        if result.encrypted.size <= 255
          expect(result.successful?).to eq true
        else
          expect(result.successful?).to eq false
        end
        expect(result.encrypted).to match(/\A[\x20-\x7E]*\z/)
      end
    end
  end

  describe 'max 4096 * 8' do
    let(:params) { {text: true, max: 4096 * 8} }
    it 'encryt 4096 size text' do
      text = 'A' * 4096
      result = interactor.call({data: text})
      expect(result.successful?).to eq true
      expect(result.encrypted).to match(/\A[\x20-\x7E]*\z/)
    end
  end
end

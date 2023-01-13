# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Decrypt do
  let(:interactor) { Decrypt.new(**params) }
  let(:params) { {text: true} }
  let(:encrypted) {
    pb_crypt = Yuzakan::Utils::PbCrypt.new(ENV.fetch('DB_SECRET'))
    pb_crypt.encrypt_text(text)
  }
  let(:text) { 'Ab01#日本語😺🀄等' }

  it 'decryt text' do
    result = interactor.call({encrypted: encrypted})
    expect(result.successful?).to eq true
    expect(result.data).to eq text
    expect(result.data.encoding).to eq Encoding::UTF_8
  end

  describe 'other password' do
    let(:params) { {password: 'abc012', text: true} }

    it 'failed decryt text other password' do
      result = interactor.call({encrypted: encrypted})
      expect(result.failure?).to eq true
      expect(result.errors.first).to eq '復号化に失敗しました。'
      expect(result.data).to be_nil
    end
  end

  describe 'other encoding' do
    let(:params) { {text: true, encoding: Encoding::WINDOWS_31J} }

    it 'decryt bad text' do
      result = interactor.call({encrypted: encrypted})
      expect(result.successful?).to eq true
      expect(result.data).not_to eq text
    end
  end
end

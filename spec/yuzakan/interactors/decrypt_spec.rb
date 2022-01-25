require_relative '../../spec_helper'

describe Decrypt do
  let(:interactor) { Decrypt.new(**params) }
  let(:params) { {text: true} }
  let(:encrypted) do
    pb_crypt = Yuzakan::Utils::PbCrypt.new(ENV.fetch('DB_SECRET'))
    pb_crypt.encrypt_text(text)
  end
  let(:text) { 'Ab01#日本語😺🀄等' }

  it 'decryt text' do
    result = interactor.call({encrypted: encrypted})
    _(result.successful?).must_equal true
    _(result.data).must_equal text
    _(result.data.encoding).must_equal Encoding::UTF_8
  end

  describe 'other password' do
    let(:params) { {password: 'abc012', text: true} }

    it 'failed decryt text other password' do
      result = interactor.call({encrypted: encrypted})
      _(result.failure?).must_equal true
      _(result.errors.first).must_equal '復号化に失敗しました。'
      _(result.data).must_be_nil
    end
  end

  describe 'other encoding' do
    let(:params) { {text: true, encoding: Encoding::WINDOWS_31J} }

    it 'decryt bad text' do
      result = interactor.call({encrypted: encrypted})
      _(result.successful?).must_equal true
      _(result.data).wont_equal text
    end
  end
end

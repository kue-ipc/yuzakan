require_relative '../../spec_helper'

describe Yuzakan::Utils::PbCrypt do
  let(:pb_crypt) { Yuzakan::Utils::PbCrypt.new(password) }
  let(:password) {
    '046c9b92e9cf4a52c132551896577bd675b472438ab7ef95f47b6ecb322a19f2'
  }

  it 'encryt and decrypt text' do
    text = 'Ab01#'
    encrypted_text = pb_crypt.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    decrypted_text = pb_crypt.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
  end

  it 'encryt and decrypt empty text' do
    text = ''
    encrypted_text = pb_crypt.encrypt_text(text)
    _(encrypted_text).must_be_empty
    decrypted_text = pb_crypt.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
  end

  it 'encryt and decrypt unicode text' do
    text = '日本語😺🀄等'
    encrypted_text = pb_crypt.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    decrypted_text = pb_crypt.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
    _(decrypted_text.encoding).must_equal Encoding::UTF_8
  end

  it 'encryt and decrypt 1..256 size text' do
    (1..256).each do |n|
      text = 'A' * n
      encrypted_text = pb_crypt.encrypt_text(text)
      _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
      _(encrypted_text).wont_equal text
      decrypted_text = pb_crypt.decrypt_text(encrypted_text)
      _(decrypted_text).must_equal text
    end
  end

  it 'encryt and decrypt 4096 size text' do
    text = 'A' * 4096
    encrypted_text = pb_crypt.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    decrypted_text = pb_crypt.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
  end

  it 'encryt and decrypt data' do
    data = 'Ab\x00\xFF23'.encode(Encoding::ASCII_8BIT)
    encrypted_data = pb_crypt.encrypt(data)
    _(encrypted_data).wont_equal data
    decrypted_data = pb_crypt.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt empty data' do
    data = ''.encode(Encoding::ASCII_8BIT)
    encrypted_data = pb_crypt.encrypt(data)
    _(encrypted_data).must_be_empty
    decrypted_data = pb_crypt.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt 1..256 size data' do
    (1..256).each do |n|
      data = "\x01".encode(Encoding::ASCII_8BIT) * n
      encrypted_data = pb_crypt.encrypt(data)
      _(encrypted_data).wont_equal data
      decrypted_data = pb_crypt.decrypt(encrypted_data)
      _(decrypted_data).must_equal data
    end
  end

  it 'encryt and decrypt 4096 size data' do
    data = (0...4096).map { |n| (n % 256).chr }
      .join.encode(Encoding::ASCII_8BIT)
    encrypted_data = pb_crypt.encrypt(data)
    _(encrypted_data).wont_equal data
    decrypted_data = pb_crypt.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt last null data' do
    data = 'Ab\x00\x00\x00\x00\x00\x00\x00\x00'.encode(Encoding::ASCII_8BIT)
    encrypted_data = pb_crypt.encrypt(data)
    _(encrypted_data).wont_equal data
    decrypted_data = pb_crypt.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt text other password' do
    text = 'Ab01#'
    encrypted_text = pb_crypt.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text

    pb_crypt_other = Yuzakan::Utils::PbCrypt.new('abc012')
    encrypted_text_other = pb_crypt_other.encrypt_text(text)
    _(encrypted_text_other).wont_equal encrypted_text

    assert_raises(OpenSSL::Cipher::CipherError) do
      pb_crypt_other.decrypt_text(encrypted_text)
    end
  end
end

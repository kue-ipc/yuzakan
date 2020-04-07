# frozen_string_literal: true

require_relative '../../spec_helper'

describe Yuzakan::Utils::Cipher do
  it 'encryt and decrypt text' do
    text = 'Ab01#'
    encrypted_text = Yuzakan::Utils::Cipher.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    decrypted_text = Yuzakan::Utils::Cipher.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
  end

  it 'encryt and decrypt empty text' do
    text = ''
    encrypted_text = Yuzakan::Utils::Cipher.encrypt_text(text)
    _(encrypted_text).must_be_empty
    decrypted_text = Yuzakan::Utils::Cipher.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
  end

  it 'encryt and decrypt unicode text' do
    text = '日本語😺🀄等'
    encrypted_text = Yuzakan::Utils::Cipher.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    decrypted_text = Yuzakan::Utils::Cipher.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
    _(decrypted_text.encoding).must_equal Encoding::UTF_8
  end

  it 'encryt and decrypt 1..256 size text' do
    (1..256).each do |n|
      text = 'A' * n
      encrypted_text = Yuzakan::Utils::Cipher.encrypt_text(text)
      _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
      _(encrypted_text).wont_equal text
      decrypted_text = Yuzakan::Utils::Cipher.decrypt_text(encrypted_text)
      _(decrypted_text).must_equal text
    end
  end

  it 'encryt and decrypt 4096 size text' do
    text = 'A' * 4096
    encrypted_text = Yuzakan::Utils::Cipher.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    decrypted_text = Yuzakan::Utils::Cipher.decrypt_text(encrypted_text)
    _(decrypted_text).must_equal text
  end

  it 'encryt and decrypt data' do
    data = 'Ab\x00\xFF23'.encode(Encoding::ASCII_8BIT)
    encrypted_data = Yuzakan::Utils::Cipher.encrypt(data)
    _(encrypted_data).wont_equal data
    decrypted_data = Yuzakan::Utils::Cipher.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt empty data' do
    data = ''.encode(Encoding::ASCII_8BIT)
    encrypted_data = Yuzakan::Utils::Cipher.encrypt(data)
    _(encrypted_data).must_be_empty
    decrypted_data = Yuzakan::Utils::Cipher.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt 1..256 size data' do
    (1..256).each do |n|
      data = "\x01".encode(Encoding::ASCII_8BIT) * n
      encrypted_data = Yuzakan::Utils::Cipher.encrypt(data)
      _(encrypted_data).wont_equal data
      decrypted_data = Yuzakan::Utils::Cipher.decrypt(encrypted_data)
      _(decrypted_data).must_equal data
    end
  end

  it 'encryt and decrypt 4096 size data' do
    data = (0...4096).map { |n| (n % 256).chr }
      .join.encode(Encoding::ASCII_8BIT)
    encrypted_data = Yuzakan::Utils::Cipher.encrypt(data)
    _(encrypted_data).wont_equal data
    decrypted_data = Yuzakan::Utils::Cipher.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt last null data' do
    data = 'Ab\x00\x00\x00\x00\x00\x00\x00\x00'.encode(Encoding::ASCII_8BIT)
    encrypted_data = Yuzakan::Utils::Cipher.encrypt(data)
    _(encrypted_data).wont_equal data
    decrypted_data = Yuzakan::Utils::Cipher.decrypt(encrypted_data)
    _(decrypted_data).must_equal data
  end

  it 'encryt and decrypt text other environment' do
    text = 'Ab01#'
    encrypted_text = Yuzakan::Utils::Cipher.encrypt_text(text)
    _(encrypted_text).must_match(/\A[\x20-\x7E]*\z/)
    _(encrypted_text).wont_equal text
    db_secret = ENV['DB_SECRET']
    ENV['DB_SECRET'] = 'abc012'
    assert_raises(OpenSSL::Cipher::CipherError) do
      Yuzakan::Utils::Cipher.decrypt_text(encrypted_text)
    end
    ENV['DB_SECRET'] = db_secret
  end
end

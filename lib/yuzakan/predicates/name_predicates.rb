# frozen_string_literal: true

require "hanami/validations"

module NamePredicates
  include Hanami::Validations::Predicates

  VALID_NAME = /\A[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*\z/
  VALID_NAME_OR_STAR = Regexp.union(VALID_NAME, /\A\*\z/).freeze
  # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
  VALID_EMAIL_ADDRESS = %r{\A
    [a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+
    @
    [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*
  \z}x
  VALID_DOMAIN =
    /\A[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/
  VALID_PASSWORD = /\A[\x20-\x7e]*\Z/

  predicate(:name?) do |current|
    current =~ VALID_NAME
  end

  predicate(:name_or_star?) do |current|
    current =~ VALID_NAME_OR_STAR
  end

  predicate(:email?) do |current|
    current =~ VALID_EMAIL_ADDRESS
  end

  predicate(:domain?) do |current|
    current =~ VALID_DOMAIN
  end

  predicate(:password?) do |current|
    current =~ VALID_PASSWORD
  end
end

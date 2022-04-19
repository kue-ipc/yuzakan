require 'hanami/validations'

module NamePredicates
  include Hanami::Validations::Predicates

  VALID_NAME = /\A[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*\z/.freeze
  VALID_NAME_OR_STAR = Regexp.union(NamePredicates::VALID_NAME, /\A\*\z/).freeze
  # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
  VALID_EMAIL_ADDRESS = %r{\A
    [a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+
    @
    [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*
  \z}x.freeze

  predicate(:name?) do |current|
    current =~ NamePredicates::VALID_NAME
  end

  predicate(:name_or_star?) do |current|
    current =~ NamePredicates::VALID_NAME_OR_STAR
  end

  predicate(:email?) do |current|
    current =~ NamePredicates::VALID_EMAIL_ADDRESS
  end
end

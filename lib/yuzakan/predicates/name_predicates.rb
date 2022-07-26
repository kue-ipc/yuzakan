require 'hanami/validations'

module NamePredicates
  include Hanami::Validations::Predicates

  # rubocop:disable Style/ClassVars
  @@valid_name = /\A[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*\z/.freeze
  @@valid_name_or_star = Regexp.union(@@valid_name, /\A\*\z/).freeze
  # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
  @@valid_email_address = %r{\A
    [a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+
    @
    [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*
  \z}x.freeze
  # rubocop:enable Style/ClassVars

  predicate(:name?) do |current|
    current =~ @@valid_name
  end

  predicate(:name_or_star?) do |current|
    current =~ @@valid_name_or_star
  end

  predicate(:email?) do |current|
    current =~ @@valid_email_address
  end
end

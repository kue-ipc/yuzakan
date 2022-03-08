require 'hanami/validations'

module NamePredicates
  include Hanami::Validations::Predicates

  predicate(:name?) do |current|
    current =~ /\A[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*\z/
  end
end

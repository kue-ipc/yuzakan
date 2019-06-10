# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class Test
  include Hanami::Interactor

  class Validations
    include Hanami::Validations

    validations do
      required(:username) { filled? }
    end
  end

   def call(params)
     pp params
   end

   private
   def valid?(params)
    validation = Validations.new(params).validate
    error(validation.messages) if validation.failure?

    validation.success?
   end
end

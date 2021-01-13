module Web
  module Controllers
    module User
      module Password
        class Edit
          include Web::Action

          expose :excluded_providers

          def call(_params)
            @excluded_providers = ProviderRepository.new
              .individual_password.to_a
          end
        end
      end
    end
  end
end

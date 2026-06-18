# frozen_string_literal: true

module API
  module Actions
    module ParamsInspection
      private def check_params(request, response)
        return if request.params.valid?

        halt_json request, response, 422, message: t("errors.invalid_params"), invalid: request.params.errors
      end

      # private def check_unique_name(request, response, repo)
      #   return unless repo.exist?(request.params[:name])

      #   halt_json request, response, 422, message: t("errors.invalid_params"), invalid: {name: [t("errors.uniq?")]}
      # end

      # private def check_existing_id(request, response, repo)
      #   return id if repo.exist?(request.params[:id])

      #   halt_json request, response, 404, message: t("errors.non_existent")
      # end

      # private def take_unique_name(request, response, repo)
      #   name = request.params[:name]
      #   return name if name.nil?
      #   return name if name == request.params[:id]
      #   return name unless repo.exist?(name)

      #   halt_json request, response, 422, message: t("errors.invalid_params"), invalid: {name: [t("errors.uniq?")]}
      # end

      # private def take_exist_id(request, response, repo)
      #   id = request.params[:id]
      #   return id if id.nil?
      #   return id if repo.exist?(id)

      #   halt_json request, response, 404, message: t("errors.non_existent"), invalid: {id: [t("errors.exist?")]}
      # end
    end
  end
end

# frozen_string_literal: true

module API
  module Actions
    module ParamsInspection
      private def check_params(request, response)
        return if request.params.valid?

        response.flash[:invalid] = request.params.errors
        halt_json request, response, 422
      end

      private def check_unique_name(request, response, repo)
        name = request.params[:name]
        return if name.nil?
        return if request.params[:id] == name
        return unless repo.exist?(name)

        response.flash[:invalid] = {name: [t("errors.uniq?")]}
        halt_json request, response, 422
      end

      private def check_exist_id(request, response, repo)
        return if repo.exist?(request.params[:id])

        halt_json request, response, 404
      end

      private def get_by_id(request, response, repo)
        struct = repo.get(request.params[:id])
        return struct if struct

        halt_json request, response, 404
      end
    end
  end
end

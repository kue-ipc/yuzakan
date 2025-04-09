# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class MenuItem < Yuzakan::Views::Part
        def path
          context.routes.path(value.name, **value.params)
        end

        def title
          context.t("title", scope: ["views", value.name])
        end

        def filename
          "#{value.name}.jsonl"
        end

        def link_tag(data: {}, **, &)
          opts =
            case type
            in :link
              {data:}
            in :modal
              {data: {"bs-toggle": "modal", "bs-target": path, **data}}
            in :download
              {data:, download: filename}
            end

          if block_given?
            helpers.link_to(path, **opts, **, &)
          else
            helpers.link_to(title, path, **opts, **)
          end
        end

        def menu_link_tag
          card_class = ["card", "border-#{value.color}"]
          card_header_class = ["card-header", "text-center"]
          card_body_class = ["card-body"]

          tag.div class: helpers.col_card + ["my-1"] do
            link_tag(class: card_class) do
              html_join(
                tag.div(title, class: card_header_class),
                tag.div(description, class: card_body_class))
            end
          end
        end
      end
    end
  end
end

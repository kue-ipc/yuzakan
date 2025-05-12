# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        def bs_navbar_brand(label)
          link_to label, "#", class: "navbar-brand"
        end

        def bs_navbar_toggler(target)
          tag.button(class: "navbar-toggler", type: "button",
            data: {bs_toggle: "collapse", bs_target: "##{target}"},
            aria: {controls: target, expanded: "false",
                   label: _context.t("ui.buttons.toggle_navigation"),}) do
            tag.span(class: "navbar-toggler-icon")
          end
        end

        def bs_divide_opts(opts)
          option_names = [:horizontal, :scope, :wrap_class, :help]
          [opts.slice(*option_names), opts.except(*option_names)]
        end

        def bs_form_control(form, name, horizontal: false, **, &)
          if horizontal
            bs_horizontal_form_control(form, name, **, &)
          else
            bs_vertical_form_control(form, name, **, &)
          end
        end

        def bs_vertical_form_control(form, name, scope: nil, help: nil,
          wrap_class: "mb-3")
          tag.div(class: wrap_class) do
            escape_join([
              form.label(t(name, scope:), for: name, class: "form-label"),
              yield(name),
              help && tag.div(help, class: "form-text"),
            ])
          end
        end

        def bs_horizontal_form_control(form, name, scope: nil, help: nil,
          wrap_class: "mb-3")
          tag.div(class: ["row", wrap_class]) do
            escape_join([
              form.label(t(name, scope:), for: name,
                class: ["col-form-label", col_name]),
              tag.div(class: col_value) { yield name },
              help && tag.div(class: col_help) do
                tag.span(help, class: "form-text")
              end,
            ])
          end
        end

        def bs_text_field(form, name, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do
            form.text_field(name, class: "form-control", **control_opts)
          end
        end

        def bs_text_area(form, name, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do
            form.text_area(name, class: "form-control", **control_opts)
          end
        end

        def bs_number_field(form, name, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do
            if control_opts[:unit]
              tag.div(class: "input-group") do
                escape_join([
                  form.number_field(name, class: "form-control",
                    **control_opts.except(:unit)),
                  tag.span(control_opts[:unit], class: "input-group-text"),
                ])
              end
            else
              form.number_field(name, class: "form-control", **control_opts)
            end
          end
        end

        def bs_select(form, name, list, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do
            form.select(name, list, class: "form-select", **control_opts)
          end
        end
      end
    end
  end
end

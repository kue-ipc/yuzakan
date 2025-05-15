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
          option_names = [:layout, :label, :scope, :wrap_class, :help]
          [opts.slice(*option_names), opts.except(*option_names)]
        end

        def bs_form_control(form, name, layout: nil, label: nil,
          scope: nil, wrap_class: "mb-3", help: nil, &)
          label ||= if scope then t(name, scope:) else name end
          case layout
          in nil | :normal
            _bs_form_control_normal(form, name,
              label:, wrap_class:, help:, &)
          in :floating
            _bs_form_control_floating(form, name,
              label:, wrap_class:, help:, &)
          in :placeholder
            _bs_form_control_placeholder(form, name,
              label:, wrap_class:, help:, &)
          in :horizontal
            _bs_form_control_horizontal(form, name,
              label:, wrap_class:, help:, &)
          end
        end

        private def _bs_form_control_normal(form, name, label:, wrap_class:,
          help:)
          tag.div(class: wrap_class) do
            escape_join([
              form.label(label, for: name, class: "form-label"),
              yield,
              help && tag.div(help, class: "form-text"),
            ])
          end
        end

        # TODO: selectやinput-groupではうまくいかない。
        private def _bs_form_control_floating(form, name, label:, wrap_class:,
          help:)
          tag.div(class: ["form-floating", wrap_class]) do
            escape_join([
              yield(placeholder: label),
              form.label(label, for: name),
              help && tag.div(help, class: "form-text"),
            ])
          end
        end

        private def _bs_form_control_placeholder(_form, _name, label:, wrap_class:,
          help:)
          tag.div(class: wrap_class) do
            escape_join([
              yield(placeholder: label, aria_label: label),
              help && tag.div(help, class: "form-text"),
            ])
          end
        end

        private def _bs_form_control_horizontal(form, name, label:, wrap_class:,
          help:, &)
          tag.div(class: ["row", wrap_class]) do
            escape_join([
              form.label(label, for: name,
                class: ["col-form-label", col_name]),
              tag.div(class: col_value, &),
              help && tag.div(class: col_help) do
                tag.span(help, class: "form-text")
              end,
            ])
          end
        end

        def bs_text_field(form, name, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do |**add_opts|
            form.text_field(name, class: "form-control", **add_opts,
              **control_opts)
          end
        end

        def bs_text_area(form, name, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do |**add_opts|
            form.text_area(name, class: "form-control", **add_opts,
              **control_opts)
          end
        end

        def bs_number_field(form, name, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do |**add_opts|
            if control_opts[:unit]
              tag.div(class: "input-group") do
                escape_join([
                  form.number_field(name, class: "form-control",
                    **add_opts, **control_opts.except(:unit)),
                  tag.span(control_opts[:unit], class: "input-group-text"),
                ])
              end
            else
              form.number_field(name, class: "form-control", **add_opts,
                **control_opts)
            end
          end
        end

        def bs_select(form, name, list, **opts)
          label_opts, control_opts = bs_divide_opts(opts)
          bs_form_control(form, name, **label_opts) do |**add_opts|
            form.select(name, list, class: "form-select", **add_opts,
              **control_opts)
          end
        end
      end
    end
  end
end

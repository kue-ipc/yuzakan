# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        class BsBuilder
          module Form
            LABEL_COL_CLASS = %w[
              col-sm-6
              col-md-4
              col-lg-3
              col-xl-2
            ].freeze

            CONTROL_COL_CLASS = %w[
              col-sm-6
              col-md-8
              col-lg-6
              col-xl-5
            ].freeze

            HELP_COL_CLASS = %w[
              col-sm-12
              offset-md-4 col-md-8
              offset-lg-0 col-lg-3
              col-xl-5
            ].freeze

            def form_control(form, name, layout: nil, label: nil, wrap_class: "mb-3",
              help: nil, &)
              label ||= name
              case layout
              in nil | :normal
                form_control_normal(form, name, label:, wrap_class:, help:, &)
              in :floating
                form_control_floating(form, name, label:, wrap_class:, help:, &)
              in :placeholder
                form_control_placeholder(form, name, label:, wrap_class:, help:, &)
              in :horizontal
                form_control_horizontal(form, name, label:, wrap_class:, help:, &)
              end
            end

            def text_field(form, name, **opts)
              label_opts, control_opts = divide_opts(opts)
              form_control(form, name, **label_opts) do |**add_opts|
                form.text_field(name, class: "form-control", **add_opts, **control_opts)
              end
            end

            # Only text_area has a specified content.
            def text_area(form, name, content = nil, **opts)
              label_opts, control_opts = divide_opts(opts)
              form_control(form, name, **label_opts) do |**add_opts|
                form.text_area(name, content, class: "form-control", **add_opts, **control_opts)
              end
            end

            def number_field(form, name, **opts)
              label_opts, control_opts = divide_opts(opts)
              form_control(form, name, **label_opts) do |**add_opts|
                if control_opts[:unit]
                  div(class: "input-group") do
                    EscapeHelper.escape_join([
                      form.number_field(name, class: "form-control", **add_opts, **control_opts.except(:unit)),
                      span(control_opts[:unit], class: "input-group-text"),
                    ])
                  end
                else
                  form.number_field(name, class: "form-control", **add_opts, **control_opts)
                end
              end
            end

            def select(form, name, list, **opts)
              label_opts, control_opts = divide_opts(opts)
              form_control(form, name, **label_opts) do |**add_opts|
                form.select(name, list, class: "form-select", **add_opts, **control_opts)
              end
            end

            private def divide_opts(opts)
              option_names = [:layout, :label, :wrap_class, :help]
              [opts.slice(*option_names), opts.except(*option_names)]
            end

            private def form_control_normal(form, name, label:, wrap_class:, help:)
              div(class: wrap_class) do
                EscapeHelper.escape_join([
                  form.label(label, for: name, class: "form-label"),
                  yield,
                  help && div(help, class: "form-text"),
                ])
              end
            end

            # TODO: selectやinput-groupではうまくいかない。
            private def form_control_floating(form, name, label:, wrap_class:,
              help:)
              div(class: ["form-floating", wrap_class]) do
                EscapeHelper.escape_join([
                  yield(placeholder: label),
                  form.label(label, for: name),
                  help && div(help, class: "form-text"),
                ])
              end
            end

            private def form_control_placeholder(_form, _name, label:, wrap_class:,
              help:)
              div(class: wrap_class) do
                EscapeHelper.escape_join([
                  yield(placeholder: label, aria_label: label),
                  help && div(help, class: "form-text"),
                ])
              end
            end

            private def form_control_horizontal(form, name, label:, wrap_class:,
              help:, &)
              div(class: ["row", wrap_class]) do
                EscapeHelper.escape_join([
                  form.label(label, for: name, class: ["col-form-label", LABEL_COL_CLASS]),
                  div(class: CONTROL_COL_CLASS, &),
                  help && div(class: HELP_COL_CLASS) do
                    div(help, class: "form-text")
                  end,
                ])
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

# I18n

Hanami.app.register_provider(:i18n) do
  prepare do
    require "i18n"
  end

  start do
    load_path = Dir["#{target.root}/config/locales/**/*.yml"]
    I18n.load_path += load_path
    I18n.backend.load_translations
    I18n.default_locale = target["settings"].locale.intern
    I18n.locale = I18n.default_locale

    register "i18n", I18n
    register "i18n.t", I18n.method(:t)
    register "i18n.l", I18n.method(:l)
  end
end

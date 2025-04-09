# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "slim"

module Yuzakan
  class View < Hanami::View
    MenuItem = Data.define(:name, :params, :color, :level) {
      def initialize(name:, color:, level:, params: {})
        super
      end
    }

    USER_STATIC_MENU_ITEMS = [
      MenuItem.new(name: :user_edit_password, color: "primary", level: 0),
    ].freeze

    ADMIN_STATIC_MENU_ITEMS = [
      MenuItem.new(name: :admin_new_user, color: "primary", level: 4),
      MenuItem.new(name: :admin_users, color: "secondary", level: 2),
      MenuItem.new(name: :admin_groups, color: "secondary", level: 2),
      MenuItem.new(name: :admin_config, color: "danger", level: 5),
      MenuItem.new(name: :admin_providers, color: "danger", level: 2),
      MenuItem.new(name: :admin_attrs, color: "danger", level: 5),
    ].freeze

    expose :current_config, as: :config, layout: true
    expose :current_user, as: :user, layout: true
    expose :current_level, layout: true

    expose :user_menu, as: :menu_item, layout: true do |current_level:|
      USER_STATIC_MENU_ITEMS.select { |item| item.level <= current_level }
    end

    expose :admin_menu, as: :menu_item, layout: true do |current_level:|
      ADMIN_STATIC_MENU_ITEMS.select { |item| item.level <= current_level }
    end
  end
end

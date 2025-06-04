# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "slim"

module Yuzakan
  class View < Hanami::View
    include Deps[
      "i18n"
    ]

    MenuItem = Data.define(:name, :params, :color, :level, :type) {
      def initialize(name:, color:, level:, params: {}, type: :link)
        super
      end
    }

    List = Data.define(:list, :scope)

    USER_STATIC_MENU_ITEMS = [
      {name: :password_edit, color: "primary", level: 1},
    ].map { |params| MenuItem.new(**params) }.freeze

    ADMIN_STATIC_MENU_ITEMS = [
      {name: :admin_user_new, color: "primary", level: 4},
      {name: :admin_users, color: "secondary", level: 2},
      {name: :admin_groups, color: "secondary", level: 2},
      {name: :admin_config, color: "danger", level: 5},
      {name: :admin_providers, color: "danger", level: 2},
      {name: :admin_attrs, color: "danger", level: 5},
    ].map { |params| MenuItem.new(**params) }.freeze

    expose :title, layout: true, decorate: false do
      nil
    end

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

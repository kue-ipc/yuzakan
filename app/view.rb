# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "slim"

module Yuzakan
  class View < Hanami::View
    include Deps["i18n"]

    MenuItem = Data.define(:name, :params, :color, :level, :type) do
      def initialize(name:, color:, level:, params: {}, type: :link)
        super
      end
    end

    List = Data.define(:list, :scope)

    USER_STATIC_MENU_ITEMS = [
      {name: :edit_password, color: "primary", level: 1},
    ].map { |params| MenuItem.new(**params) }.freeze

    ADMIN_STATIC_MENU_ITEMS = [
      {name: :new_admin_user, color: "primary", level: 4},
      {name: :admin_users, color: "secondary", level: 2},
      {name: :admin_groups, color: "secondary", level: 2},
      {name: :admin_config, color: "danger", level: 5},
      {name: :admin_services, color: "danger", level: 2},
      {name: :admin_attrs, color: "danger", level: 5},
    ].map { |params| MenuItem.new(**params) }.freeze

    expose :title, layout: true do
      nil
    end

    decorate :current_config, as: :config, layout: true
    decorate :current_user, as: :user, layout: true
    decorate :current_level, layout: true

    decorate :user_menu, as: :menu_item, layout: true do |current_level|
      USER_STATIC_MENU_ITEMS.select { |item| item.level <= current_level }
    end

    decorate :admin_menu, as: :menu_item, layout: true do |current_level|
      ADMIN_STATIC_MENU_ITEMS.select { |item| item.level <= current_level }
    end
  end
end

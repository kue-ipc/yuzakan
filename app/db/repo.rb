# frozen_string_literal: true

require "hanami/db/repo"

module Yuzakan
  module DB
    class Repo < Hanami::DB::Repo
      CREATE_TIMESTAMP = {
        use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}},
      }.freeze
      UPDATE_TIMESTAMP = {
        use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}},
      }.freeze
    end
  end
end

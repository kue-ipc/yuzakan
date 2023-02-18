# frozen_string_literal: true

class Group < Hanami::Entity
  def label_name
    if display_name
      "#{display_name} (#{name})"
    else
      name
    end
  end

  def label
    display_name || name
  end

  def to_s
    name
  end
end

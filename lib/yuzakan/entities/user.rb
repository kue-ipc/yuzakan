# frozen_string_literal: true

# User clearance level
# 5: supervisor
# 4: administrator
# 3: operator
# 2: monitor
# 1: user
# 0: guest

class User < Hanami::Entity
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

  def deleted?
    deleted
  end

  def prohibited?
    prohibited
  end

  def to_s
    name
  end

  def primary_group
    members&.find(&:primary)&.group
  end

  def supplementary_groups
    members&.reject(&:primary)&.map(&:group)
  end

  def groups
    members&.map(&:group)
  end
end

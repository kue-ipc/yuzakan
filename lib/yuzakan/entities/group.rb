# frozen_string_literal: true

class Group < Hanami::Entity
  def name
    Hanami.logger.warn('call Group#name')
    groupname
  end

  def label_name
    if display_name
      "#{display_name} (#{groupname})"
    else
      groupname
    end
  end

  def label
    display_name || groupname
  end

  def to_s
    groupname
  end
end

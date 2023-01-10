# User clearance level
# 5: supervisor
# 4: administrator
# 3: operator
# 2: monitor
# 1: user
# 0: guest

class User < Hanami::Entity
  def name
    Hanami.logger.warn('call User#name')
    username
  end

  def label_name
    if display_name
      "#{display_name} (#{username})"
    else
      username
    end
  end

  def label
    display_name || username
  end

  def deleted?
    deleted
  end

  def reseverd?
    reserved
  end

  def to_s
    username
  end

  def primary_group
    members&.find(&:primry)&.group
  end

  def groups
    members&.map(&:group)
  end
end

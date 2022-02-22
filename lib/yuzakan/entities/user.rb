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

  def to_s
    name
  end
end

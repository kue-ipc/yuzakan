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

  def clearance_level
    if admin
      5
    else
      2
    end
  end
end

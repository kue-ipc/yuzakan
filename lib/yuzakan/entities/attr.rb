class Attr < Hanami::Entity
  def label_name
    if display_name
      "#{display_name} (#{name})"
    else
      name
    end
  end
end

class Attr < Hanami::Entity
  TYPES = %w[
    boolean
    string
    integer
    float
    date
    time
    datetime
  ].freeze

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
end

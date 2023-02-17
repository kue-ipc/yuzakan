# frozen_string_literal: true

class GroupRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :users, through: :members
  end

  def ordered_all
    groups.order(:groupname).to_a
  end

  def ordered_filter(order: {groupname: :asc}, filter: {})
    order = {groupname: :asc} if order.nil? || order.empty?

    order_attributes = order.map do |key, value|
      case value.downcase.intern
      when :asc
        groups[key].qualified.asc
      when :desc
        groups[key].qualified.desc
      end
    end.compact

    filter(**filter).order(*order_attributes)
  end

  def search(query: nil, match: :partial)
    return groups if query.nil? || query.empty?

    sql_query =
      case match
      when :extract
        query
      when :forward
        "#{query}%"
      when :backward
        "%#{query}"
      when :partial
        "%#{query}%"
      end
    groups.where { groupname.ilike(sql_query) | display_name.ilike(sql_query) }
  end

  def filter(search: nil, primary: nil, prohibited: nil, deleted: nil)
    q = groups
    search(**search) if search
    q = q.where { groupname.ilike("%#{query}%") | display_name.ilike("%#{query}%") } if query&.size&.positive?

    q = q.where(primary: primary) unless primary.nil?

    q = q.where(prohibited: prohibited) unless prohibited.nil?

    case deleted
    when true, false
      q = q.where(deleted: deleted)
    when Range
      q = q.where(deleted: true).where(deleted_at: deleted)
    end

    q
  end

  def by_groupname(groupname)
    groups.where(groupname: groupname)
  end

  def all_by_groupname(groupnames)
    by_groupname(groupnames).to_a
  end

  def find_by_groupname(groupname)
    by_groupname(groupname).one
  end

  def find_or_create_by_groupname(groupname)
    find_by_groupname(groupname) || create({groupname: groupname})
  end

  def add_user(group, user)
    member = member_for(group, user).one
    return if member

    assoc(:members, group).add(user_id: user.id)
  end

  def remove_user(group, user)
    member = member_for(group, user).one
    return unless member

    assoc(:members, group).remove(member.id)
  end

  private def member_for(group, user)
    assoc(:members, group).where(user_id: user.id)
  end
end
